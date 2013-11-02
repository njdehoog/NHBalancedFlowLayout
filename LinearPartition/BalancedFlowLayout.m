//
//  BalancedFlowLayout.m
//  LinearPartition
//
//  Created by Niels de Hoog on 31/10/13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import "BalancedFlowLayout.h"
#import "LinearPartition.h"

@interface BalancedFlowLayout ()

@property (nonatomic) NSUInteger numberOfRows;

@property (nonatomic, strong) NSArray *itemSizes;

@end

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
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.minimumLineSpacing = 10;
}

- (void)prepareLayout
{
    NSAssert([self.collectionView.delegate conformsToProtocol:@protocol(BalancedFlowLayoutDelegate)], @"UICollectionView delegate should conform to BalancedFlowLayout protocol");
    id<BalancedFlowLayoutDelegate> delegate = (id<BalancedFlowLayoutDelegate>)self.collectionView.delegate;
    
    CGFloat viewportWidth = CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.left - self.sectionInset.right;
    CGFloat idealHeight = CGRectGetHeight(self.collectionView.bounds) / 2.0;
    self.preferredRowHeight = idealHeight;
    
    CGFloat totalImageWidth = 0;
    for (int i = 0, n = [self.collectionView numberOfItemsInSection:0]; i < n; i++) {
        CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        totalImageWidth += (preferredSize.width / preferredSize.height) * idealHeight;
    }
    
    self.numberOfRows = roundf(totalImageWidth / viewportWidth);
    
    NSMutableArray *itemSizes = [NSMutableArray array];
    if (self.numberOfRows < 1) {
        for (int i = 0, n = [self.collectionView numberOfItemsInSection:0]; i < n; i++) {
            CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            CGSize actualSize = CGSizeMake(roundf((preferredSize.width / preferredSize.height) * self.preferredRowHeight), roundf(self.preferredRowHeight));
            [itemSizes addObject:[NSValue valueWithCGSize:actualSize]];
        }
    }
    else {
        NSMutableArray *weights = [NSMutableArray array];
        for (int i = 0, n = [self.collectionView numberOfItemsInSection:0]; i < n; i++) {
            CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            NSInteger aspectRatio = roundf((preferredSize.width / preferredSize.height) * 100);
            [weights addObject:@(aspectRatio)];
        }
        
        NSArray *partition = [LinearPartition linearPartitionForSequence:weights numberOfPartitions:self.numberOfRows];
        
        int i = 0;
        for (NSArray *row in partition) {
            
            CGFloat summedRatios = 0;
            for (int j = i, n = i + [row count]; j < n; j++) {
                CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:0]];
                summedRatios += preferredSize.width / preferredSize.height;
            }
            
            for (int j = i, n = i + [row count]; j < n; j++) {
                CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:0]];
                CGSize actualSize = CGSizeMake(roundf(viewportWidth / summedRatios * (preferredSize.width / preferredSize.height)), roundf(viewportWidth / summedRatios));
                [itemSizes addObject:[NSValue valueWithCGSize:actualSize]];
            }
            
            i += [row count];
        }
    }
    
    self.itemSizes = [itemSizes copy];
}

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.itemSizes objectAtIndex:indexPath.item] CGSizeValue];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *items = [super layoutAttributesForElementsInRect:rect];
    for (UICollectionViewLayoutAttributes *attributes in items) {
//        attributes.size = [self sizeForItemAtIndexPath:attributes.indexPath];
    }
    
    return items;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [super layoutAttributesForItemAtIndexPath:indexPath];
}

@end
