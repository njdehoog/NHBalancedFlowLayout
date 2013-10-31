//
//  BalancedFlowLayout.m
//  LinearPartition
//
//  Created by Niels de Hoog on 31/10/13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import "BalancedFlowLayout.h"

@implementation BalancedFlowLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
//    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//    self.minimumLineSpacing = 10;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *items =  [super layoutAttributesForElementsInRect:rect];
    
    [items enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {
//        attributes.transform = CGAffineTransformMakeScale(0.7, 0.7);
    }];
    
    return items;
}

@end
