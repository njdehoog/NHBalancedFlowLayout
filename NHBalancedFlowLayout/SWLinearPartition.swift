//
//  NHLinearPartition.swift
//  NHBalancedFlowLayoutDemo
//
//  Created by Niels de Hoog on 08/06/14.
//  Copyright (c) 2014 Niels de Hoog. All rights reserved.
//

import Foundation

struct Matrix {
    let rows: Int, columns: Int
    var grid: Int[]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        
        grid = Array(count: rows * columns, repeatedValue: 0)
    }
    
    func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    subscript(row: Int, column: Int) -> Int {
        get {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            return grid[(row * columns) + column]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            grid[(row * columns) + column] = newValue
        }
    }
}

@objc class SWLinearPartition {

    @objc class func linearPartitionForSequence(sequence: Array<Int>, numberOfPartitions: Int) -> Array<Array<Int>> {
        var n = sequence.count
        var k = numberOfPartitions
        
        assert(k > 0, "number of partitions must be larger than 0")
        
        if k > n {
            return sequence.map({
                (number: Int) -> Array<Int> in
                return [number]
            })
        }
        
        if n == 1 { return [sequence] }
        
        var solution = linearPartitionTableForSequence(sequence, numberOfPartitions: numberOfPartitions)
        
        k = k - 2;
        n = n - 1;
        
        var answer: Array<Array<Int>> = Array()

        while k >= 0 {
            if (n < 1) {
                answer.insert([], atIndex: 0)
            }
            else {
                var currentAnswer = Int[]()
                for i in (solution[n - 1, k] + 1)..(n + 1) {
                    currentAnswer.append(sequence[i])
                }
                answer.insert(currentAnswer, atIndex: 0)
                
                n = solution[n - 1 , k]
            }
            
            --k
        }
        
        var currentAnswer = Int[]()
        for i in 0..(n + 1) {
            currentAnswer.append(sequence[i])
        }
        
        answer.insert(currentAnswer, atIndex: 0)
        
        return answer
    }
    
    class func linearPartitionTableForSequence(sequence: Array<Int>, numberOfPartitions: Int) -> Matrix {
        
        // TODO: should not recalculate n
        let n = sequence.count
        let k = numberOfPartitions
        
        var tempTable = Matrix(rows: n, columns: k)
        var solutionTable = Matrix(rows: n - 1, columns: k - 1)
        
        // fill table with initial values
        for i in 0..n {
            let offset = i > 0 ? tempTable[i - 1, 0] : 0
            tempTable[i, 0] = sequence[i] + offset
        }
        
        for i in 0..k {
            tempTable[0, i] = sequence[0]
        }

        // calculate the costs and fill the solution buffer
        for i in 1..n {
            for j in 1..k {
                var currentMin = 0
                var minX = Int.max
                
                for x in 0..i {
                    let c1 = tempTable[x, j - 1]
                    let c2 = tempTable[i, 0] - tempTable[x, 0]
                    let cost = max(c1, c2)
                    
                    if (x == 0 || cost < currentMin) {
                        currentMin = cost
                        minX = x
                    }
                }
                
                tempTable[i, j] = currentMin
                solutionTable[i - 1, j - 1] = minX
            }
        }
        
        return solutionTable
    }
    

}