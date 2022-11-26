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
    
    //TODO: - Set up generic initializer to handle both array and set arguments
    /**
     Initialization accepts a 2 dimensional Int array. The top level should be the rows the second level should be an array of column indices
     */
    public init(exactCover grid: [[Int]]) {
        self.grid = SDLXGrid(grid.map{Set($0)})
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
     Solve the grid first covering the provided rows and attempt to solve it exactly n number of times
     
     This is a general use method of implementing the generate method however generate can be used in other methods.
     */
    public mutating func solve(_ rows: Set<Int> = [], _ times: Int) -> Set<Int>? {
        guard let cache = grid.cover(rows) else {
            print("This is an unsolvable set of rows")
            return nil
        }
        history += rows
        defer{
            grid.uncover(cache)
            history -= rows
        }
        var count = 0
        return generate{
            count += 1
            return count == times ? $0:nil
        }
    }
    
    @discardableResult
    public mutating func generate(each: (Set<Int>) -> Set<Int>?) -> Set<Int>? {
        guard let column = pickColumn() else {
            return each(history)
        }
        for r in column {
            guard let cache = grid.cover(r) else {continue}
            history += r
            defer{
                history -= r
                grid.uncover(cache)
            }
            guard let solution = generate(each: each) else {continue}
            return solution
        }
        return nil
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
            guard let sol = minimalSolve(minSize) else {continue} //solution was found
            guard solution == nil else {return nil} //previous solution does not exist
            guard history.count > minSize else {return history} //current solution is greater then the minSize parameter
            solution = history //Using history as the returned value will be the second to last.
        }
        return history
    }
}


