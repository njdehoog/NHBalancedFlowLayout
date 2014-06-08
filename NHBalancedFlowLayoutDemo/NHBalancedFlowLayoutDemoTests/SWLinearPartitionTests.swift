//
//  TempTest.swift
//  NHBalancedFlowLayoutDemo
//
//  Created by Niels de Hoog on 08/06/14.
//  Copyright (c) 2014 Niels de Hoog. All rights reserved.
//

import XCTest
import NHBalancedFlowLayoutDemo

class SWLinearPartitionTests: XCTestCase {

    func testExample() {
        let sequence = [9,2,6,3,8,5,8,1,7,3,4]
        let numberOfPartitions = 3
        let partition = SWLinearPartition.linearPartitionForSequence(sequence, numberOfPartitions: numberOfPartitions)
        
        XCTAssert(partition == [[9,2,6,3],[8,5,8],[1,7,3,4]], "should be equal to array")
    }
    
    func testNumberOfPartitionsEqualToSequenceCount() {
        let sequence = [346, 146, 125]
        let numberOfPartitions = 3
        let partition = SWLinearPartition.linearPartitionForSequence(sequence, numberOfPartitions: numberOfPartitions)
        
        XCTAssert(partition.count == numberOfPartitions, "should contain 3 objects");
    }
    
    func testOutOfBoundsException() {
        let sequence = [346, 150, 125, 71, 137]
        let numberOfPartitions = 4
        let partition = SWLinearPartition.linearPartitionForSequence(sequence, numberOfPartitions: numberOfPartitions)
        
        XCTAssert(partition.count == numberOfPartitions, "should contain 4 objects");
    }
}
