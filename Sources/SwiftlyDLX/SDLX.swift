//
//  SDLX.swift
//  
//
//  Created by James Irwin on 11/19/22.
//

import Foundation

/**
 This will be where the magic happens
 
 For now everything will be public however I dont think the final version will expose all the inner workings
 */
public enum DLXError : Error {
    case runtimeError(String)
}


public struct SDLX {
    public var grid : SDLXGrid
    public var history : Set<Int> = []
    
    public var comparator : (Int, Int) -> Bool = {$0 > $1}
    //MARK: - Initializers
    /**
     Initialization using a grid of bools to represent a basic exact cover grid
     */
    public init(exactCover grid: [[Bool]]) {
        //Need to know the total number of columns necessary. Not every constraint has to apply to every possible value... not saying its a good practice but there are corner cases where this may be true
        
        var rs: [Set<Int>] = []
        for r in grid {
            var rw = Set<Int>()
            for (j, c) in r.enumerated() where c {
                rw += j
            }
            rs.append(rw)
        }
        
        self.grid = SDLXGrid(rs)
    }
    
    
    /**
     Initialization accepts an array of integer Sets. This should essencially be the representation of the rows being used.
     */
    public init(exactCover grid: [Set<Int>]) {
        self.grid = SDLXGrid(grid)
    }
    
    //MARK: - Hueristics
    
    public func pickColumn() -> Set<Int>? {
        return grid.columns.max{comparator($0.value.count, $1.value.count)}?.value
    }
    
    //MARK: - Solving Methods
    
    
    /**
     Depreciation notice - This method potentially will return inconsistent nil mean it is either not solvable or not solvable a total number of times. Instead a new method will be made to simplify this and solve will remain a singleton method instead.
     Solve the grid first covering the provided rows and attempt to solve it exactly n number of times
     
     This is a general use method of implementing the generate method however generate can be used in other methods.
     */
    public mutating func solve(_ rows: Set<Int> = []) -> Set<Int>? {
        guard let cache = cover(rows) else {return nil}
        defer{uncover(rows, cache)}
        
        return generate{$0}
    }
    
    public mutating func cover(_ row: Int) -> Set<Int>? {
        guard let cache = grid.cover(row) else {return nil}
        history += row
        return cache
    }
    
    public mutating func cover(_ rows: Set<Int>) -> Set<Int>? {
        guard let cache = grid.cover(rows) else {return nil}
        history += rows
        return cache
    }
    
    public mutating func uncover(_ row: Int, _ cache: Set<Int>) {
        history -= row
        grid.uncover(cache)
    }
    
    public mutating func uncover(_ rows: Set<Int>, _ cache: Set<Int>) {
        history -= rows
        grid.uncover(cache)
    }
    
    /**
     Attempts to find n number of solutions with the given partial set of solutions
     */
    public mutating func attempt(rows: Set<Int> = [],_ times: Int) -> Set<Set<Int>> {
        var solutions : Set<Set<Int>> = []
        guard let cache = grid.cover(rows) else {
            print("This is not a solvable partial")
            return solutions}
        history += rows
        defer{
            grid.uncover(cache)
            history -= rows
        }
        
        generate{
            solutions += $0
            return solutions.count == times ? $0:nil
        }
        return solutions
    }
    
    @discardableResult
    public mutating func generate(each: (Set<Int>) -> Set<Int>?) -> Set<Int>? {
        guard let column = pickColumn() else {
            return each(history)
        }
        for r in column {
            guard let cache = cover(r) else {continue}
            defer{uncover(r, cache)}
            if let solution = generate(each: each) { return solution }
        }
        return nil
    }
    
    /**
     This is an experimental method which will try to determine a partial solution that only has one possible solution.
     */
    
    
    public mutating func simplify(_ master: Set<Int>,_ size: Int) -> Set<Int>? {
        var partial: Set<Int> = []
        var attempts: Int = 0
        var topLevel: Int = 0
        func cmb(_ remaining: Set<Int>,_ top: Bool = false) -> Set<Int>? {
            guard partial.count < size else {
                attempts += 1
                let valid = attempt(2).count == 1
                print("Attempt \(attempts) \(valid) \(remaining.count) \(topLevel)")
                return valid ? partial:nil
            }
            var rem = remaining
            for r in filterByWeight(remaining) {
                if top {
                    topLevel += 1
                }
                guard partial.count + rem.count >= size else {
                    print("No point in proceeding")
                    return nil
                }
                guard let cache = cover(r) else {
                    print("This shouldn't be able to happen")
                    return nil
                }
                partial += r
                rem -= r
                defer{
                    partial -= r
                    uncover(r, cache)
                }
                guard let p = cmb(rem) else {continue}
                return p
            }
            return nil
        }
        return cmb(master, true)
    }
    
    func sortByWeight(_ rows: Set<Int>) -> [Int] {
        let list = Array(rows)
        let mags = list.map{grid.rowWeight($0)}
        return list.indices.sorted{mags[$0] > mags[$1]}.map{list[$0]}
    }
    
    func filterByWeight(_ rows: Set<Int>) -> Set<Int> {
        let list = Array(rows)
        let mags = list.map{grid.rowWeight($0)}
        guard let max = mags.max() else {return []}
        return Set(list.indices.filter{mags[$0] == max}.map{list[$0]})
    }
    
    func sortRowsByMagnitude(_ rows: Set<Int>) -> [Int] {
        let list = Array(rows)
        let mags = list.map{grid.rowMagnitude($0)}
        return list.indices.sorted{mags[$0] > mags[$1]}.map{list[$0]}
    }
    
    func filterByMagnitude(_ rows: Set<Int>) -> Set<Int> {
        let list = Array(rows)
        let mags = list.map{grid.rowMagnitude($0)}
        guard let max = mags.max() else {return []}
        return Set(list.indices.filter{mags[$0] == max}.map{list[$0]})
    }

    
    
    
    /**
     attempt to find the smallest version of the grid which only has one result. This will have a long runtime and at this time cannot be canceled. The minSize will be a method to for the function to return early if it finds a solution that is  less then or equal to the minimium Size
     */
    public mutating func minimal(_ rows: Set<Int>,_ minSize: Int = 0) -> Set<Int>? {
        guard let cache = grid.cover(rows) else {
            print("The provided set of rows has no possible solution")
            return nil
        }
        history += rows
        defer{
            grid.uncover(cache)
            history -= rows
        }
        
        return minimalSolve(minSize)
    }
    
    /** WARNING: - The runtime of this method can be extensive and will be blocking. at this time its not cancelable. Later this will be changed*/
    private mutating func minimalSolve(_ minSize: Int) -> Set<Int>? {
        guard let column = pickColumn() else { //If no columns left the puzzle is solved so there must only be one solution at this point
            return history
        }
        var solution: Set<Int>? = nil
        for r in column {
            guard let cache = grid.cover(r) else {continue} //This row cannot be solved
            history += r
            defer{
                grid.uncover(cache)
                history -= r
            }
            guard let _ = minimalSolve(minSize) else {continue} //solution was found
            guard solution == nil else {return nil} //previous solution does not exist
            guard history.count > minSize else {return history} //current solution is greater then the minSize parameter
            solution = history //Using history as the returned value will be the second to last.
        }
        return history
    }
    
    
    //MARK: - Static methods
    
    
}


