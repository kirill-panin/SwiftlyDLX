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
                rw.insert(j)
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
     Attempt to solve and return first solution found
     */
    public mutating func solve() -> Set<Int>? {
        return generate{ solution in
            return solution
        }
    }
    
    @discardableResult
    public mutating func generate(each: (Set<Int>) -> Set<Int>?) -> Set<Int>? {
        guard let column = pickColumn() else {
            return each(history)
        }
        for r in column {
            guard let cache = grid.cover(r) else {continue}
            history.insert(r)
            defer{
                history.remove(r)
                grid.uncover(cache)
            }
            guard let solution = generate(each: each) else {continue}
            return solution
        }
        return nil
    }
}


