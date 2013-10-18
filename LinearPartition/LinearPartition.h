//
//  LinearPartition.h
//  LinearPartition
//
//  Created by Niels de Hoog on 08-10-13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LinearPartition : NSObject

+ (NSArray *)linearPartitionForSequence:(NSArray *)sequence numberOfPartitions:(NSInteger)numberOfPartitions;

@end
