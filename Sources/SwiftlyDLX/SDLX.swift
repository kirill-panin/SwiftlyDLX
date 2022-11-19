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
    public let rows: [Set<Int>] //Aside from during initialization this will be a constant... a rock... it wont change
    public var columns: [Int: Set<Int>]
    public var history: [Set<Int>] = []
    
    /**
     Initialization using a grid of bools to represent a basic exact cover grid
     */
    public init(exactCover grid: [[Bool]]) {
        //Need to know the total number of columns necessary. Not every constraint has to apply to every possible value... not saying its a good practice but there are corner cases where this may be true
        let maxCol = grid.max{$0.count < $1.count}?.count ?? 0
        columns = [:]
        //Construct empty columns
        columns = Self.buildColumns(of: maxCol)
        
        var rs: [Set<Int>] = []
        for (i,r) in grid.enumerated() {
            var rw = Set<Int>()
            for (j, c) in r.enumerated() where c {
                rw.insert(j)
                columns[j]?.insert(i)
                
            }
            rs.append(rw)
        }
        
        self.rows = rs
    }
    
    //TODO: - Set up generic initializer to handle both array and set arguments
    public init(exactCover grid: [[Int]]) {
        let maxCol = grid.map{$0.max() ?? 0}.max() ?? 0
        columns = Self.buildColumns(of: maxCol)
        var rs = [Set<Int>]()
        for (i, r) in grid.enumerated() {
            let rw = Set(r) //removes duplicates... just in case
            for c in rw {
                columns[c]?.insert(i)
            }
            rs.append(rw)
        }
        rows = rs
    }
    
    public init(exactCover grid: [Set<Int>]) {
        let maxCol = grid.map{$0.max() ?? 0}.max() ?? 0
        columns = Self.buildColumns(of: maxCol)
        rows = grid
        for (i, r) in grid.enumerated() {
            for c in r {
                columns[c]?.insert(i)
            }
        }
    }
    
    
    //MARK: - Static Helper Methods
    
    static func buildColumns(of size: Int) -> [Int:Set<Int>] {
        var cs : [Int:Set<Int>] = [:]
        for i in 0..<size {
            cs[i] = Set()
        }
        return cs
    }
}


