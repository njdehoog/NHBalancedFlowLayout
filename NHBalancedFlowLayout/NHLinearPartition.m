//
//  LinearPartition.m
//  BalancedFlowLayout
//
//  Created by Niels de Hoog on 08-10-13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import "NHLinearPartition.h"

@implementation NHLinearPartition

+ (NSArray *)linearPartitionForSequence:(NSArray *)sequence numberOfPartitions:(NSInteger)numberOfPartitions
{
    NSInteger n = [sequence count];
    NSInteger k = numberOfPartitions;
    
    if (k <= 0) return @[];
    
    if (k >= n) {
        NSMutableArray *partition = [[NSMutableArray alloc] init];
        [sequence enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [partition addObject:@[obj]];
        }];
        return [partition copy];
    }
    
    if (n == 1) {
        return @[sequence];
    }
    
    NSMutableArray *table = [NSMutableArray array];
    NSMutableArray *solution = [NSMutableArray array];
    for (int i = 0; i < n; i++) {
        NSMutableArray *row = [NSMutableArray array];
        NSMutableArray *solutionRow = [NSMutableArray array];
        for (int j = 0; j < k; j++) {
            [row addObject:@0];
            
            if (j < k -1) {
                [solutionRow addObject:@0];
            }
        }
        [table addObject:row];
        
        if (i < n -1) {
            [solution addObject:solutionRow];
        }
    }
    
    for (int i = 0; i < n; i++) {
        table[i][0] = i ? @([sequence[i] integerValue] + [table[i-1][0] integerValue]) : sequence[i];
    }
    
    for (int i = 0; i < k; i++) {
        table[0][i] = sequence[0];
    }
    
    for (int i = 1; i < n; i++) {
        for (int j = 1; j < k; j++) {
            
            NSMutableArray *m = [NSMutableArray array];
            for (int x = 0; x < i; x++) {
                m[x] = @{@"0": @(MAX([table[x][j-1] integerValue], [table[i][0] integerValue] - [table[x][0] integerValue])), @"1": @(x)};
            }
            
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"0" ascending:YES];
            [m sortUsingDescriptors:@[sortDescriptor]];
            
            table[i][j] = m[0][@"0"];
            solution[i-1][j-1] = m[0][@"1"];
        }
    }
    
    k = k - 2;
    n = n - 1;
    NSMutableArray *answer = [NSMutableArray array];
    while (k >= 0) {
        NSMutableArray *currentAnswer = [NSMutableArray array];
        for (NSInteger i = [solution[n-1][k] integerValue] + 1, range = n+1; i < range; i++) {
            [currentAnswer addObject:sequence[i]];
        }
        
        [answer insertObject:currentAnswer atIndex:0];
        
        n = [solution[n-1][k] integerValue];
        k = k - 1;
    }
    
    NSMutableArray *currentAnswer = [NSMutableArray array];
    for (NSInteger i = 0, range = n + 1; i < range; i++) {
        [currentAnswer addObject:sequence[i]];
    }
    
    [answer insertObject:currentAnswer atIndex:0];
    
    return [answer copy];
}

@end



