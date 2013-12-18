//
//  LinearPartitionTests.m
//  LinearPartitionTests
//
//  Created by Niels de Hoog on 08-10-13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NHLinearPartition.h"

@interface LinearPartitionTests : XCTestCase

@end

@implementation LinearPartitionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNumberOfPartitionsEqualToSequenceCount
{
    NSArray *sequence = @[@346, @146, @125];
    NSInteger numberOfPartitions = 3;
    
    NSArray *partition = [NHLinearPartition linearPartitionForSequence:sequence numberOfPartitions:numberOfPartitions];
    XCTAssertNotNil(partition, @"should return valid partition");
    XCTAssert([partition count] == numberOfPartitions, @"should contain 3 objects");
}

- (void)testOutOfBoundsException
{
    NSArray *sequence = @[@346, @150, @125, @71, @137];
    NSInteger numberOfPartitions = 4;
    
    NSArray *partition = [NHLinearPartition linearPartitionForSequence:sequence numberOfPartitions:numberOfPartitions];
    XCTAssertNotNil(partition, @"should return valid partition");
    XCTAssert([partition count] == numberOfPartitions, @"should contain 4 objects");
}

@end
