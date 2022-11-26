//
//  SDLXGrid.swift
//  
//
//  Created by James Irwin on 11/19/22.
//

import Foundation

/**
 A representation of the exact Cover Grid
 */
public struct SDLXGrid {
    let rows : [Set<Int>]
    var columns : [Int:Set<Int>] = [:]
    
    public init(_ grid: [Set<Int>]) {
        rows = grid
        //Precreating the columns may create arrays for empty columns which will cause errors later incorrectly. However if copying a SDLXGrid one should only need to initialize a new variable as structs are by value.
        for (i, r) in grid.enumerated() {
            for c in r {
                var column = columns[c] ?? []
                column.insert(i)
                columns[c] = column
            }
        }
    }
    
    //MARK: - Mutators
    public mutating func cover(_ row: Int) -> Set<Int>? {
        guard let cache = removeColumns(for: row) else {return nil}
        //remove remaining columns from the grid
        for r in cache {
            for c in rows[r] {
                guard columns[c] != nil else {continue}
                columns[c]!.remove(r)
            }
        }
        return cache
    }
    
    public mutating func cover(_ rows: Set<Int>) -> Set<Int>? {
        var cache: Set<Int> = []
        for i in rows {
            guard let c = cover(i) else {
                uncover(cache)
                return nil
            }
            cache.formUnion(c)
        }
        return cache
    }
    public mutating func uncover(_ cache: Set<Int>) {
        for r in cache {
            for c in rows[r] {
                var column: Set<Int> = columns[c] ?? []
                column.insert(r)
                columns[c] = column
            }
        }
    }
    
    public mutating func removeColumns(for row: Int) -> Set<Int>? {
        var cache: Set<Int> = []
        print(row)
        for c in rows[row] {
            guard let nc = columns.removeValue(forKey: c) else {
                uncover(cache)
                return nil
            }
            cache.formUnion(nc)
        }
        return cache
    }
}
