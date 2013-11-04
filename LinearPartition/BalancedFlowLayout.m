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

@property (nonatomic) CGSize contentSize;
@property (nonatomic, strong) NSArray *itemFrames;

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
//    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
//    self.minimumLineSpacing = 10;
}

- (void)prepareLayout
{
    NSAssert([self.collectionView.delegate conformsToProtocol:@protocol(BalancedFlowLayoutDelegate)], @"UICollectionView delegate should conform to BalancedFlowLayout protocol");
    id<BalancedFlowLayoutDelegate> delegate = (id<BalancedFlowLayoutDelegate>)self.collectionView.delegate;
    
    CGFloat viewportWidth = CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.left - self.sectionInset.right;
    CGFloat idealHeight = self.preferredRowHeight > 0 ?: CGRectGetHeight(self.collectionView.bounds) / 2.0;
    
    CGFloat totalImageWidth = 0;
    for (int i = 0, n = [self.collectionView numberOfItemsInSection:0]; i < n; i++) {
        CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        totalImageWidth += (preferredSize.width / preferredSize.height) * idealHeight;
    }
    
    NSInteger numberOfRows = roundf(totalImageWidth / viewportWidth);
    
    NSMutableArray *itemFrames = [NSMutableArray array];
    if (numberOfRows < 1) {
        for (int i = 0, n = [self.collectionView numberOfItemsInSection:0]; i < n; i++) {
//            CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
//            CGSize actualSize = CGSizeMake(roundf((preferredSize.width / preferredSize.height) * self.preferredRowHeight), roundf(self.preferredRowHeight));
            
            // TODO: implement this branch
        }
    }
    else {
        NSMutableArray *weights = [NSMutableArray array];
        for (int i = 0, n = [self.collectionView numberOfItemsInSection:0]; i < n; i++) {
            CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            NSInteger aspectRatio = roundf((preferredSize.width / preferredSize.height) * 100);
            [weights addObject:@(aspectRatio)];
        }
        
        NSArray *partition = [LinearPartition linearPartitionForSequence:weights numberOfPartitions:numberOfRows];
        
        int i = 0;
        CGPoint offset = CGPointZero;
        CGFloat previousItemHeight = 0;
        CGFloat contentHeight = 0;
        for (NSArray *row in partition) {
  
            CGFloat summedRatios = 0;
            for (int j = i, n = i + [row count]; j < n; j++) {
                CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:0]];
                summedRatios += preferredSize.width / preferredSize.height;
            }
            
            for (int j = i, n = i + [row count]; j < n; j++) {
                CGSize preferredSize = [delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:0]];
                CGSize actualSize = CGSizeMake(roundf(viewportWidth / summedRatios * (preferredSize.width / preferredSize.height)), roundf(viewportWidth / summedRatios));
                
                // move to next line
                if (offset.x + actualSize.width > viewportWidth) {
                    offset = CGPointMake(0, offset.y + previousItemHeight);
                }
                
                CGRect frame = CGRectMake(offset.x, offset.y, actualSize.width, actualSize.height);
                [itemFrames addObject:[NSValue valueWithCGRect:frame]];
                
                offset.x += actualSize.width;
                previousItemHeight = actualSize.height;
                contentHeight = CGRectGetMaxY(frame);
            }
            
            i += [row count];
        }
        
        self.contentSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), contentHeight);
    }
    
    self.itemFrames = [itemFrames copy];
    
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *layoutAttributes = [NSMutableArray array];
    
    NSArray *visibleIndexPaths = [self indexPathsForItemsInRect:rect];
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        [layoutAttributes addObject:[self layoutAttributesForItemAtIndexPath:indexPath]];
    }
    
    return layoutAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.frame = [[self.itemFrames objectAtIndex:indexPath.item] CGRectValue];
    
    return attributes;
}

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect
{
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
    }
    return [indexPaths copy];
}

#pragma mark - Custom setters

- (void)setPreferredRowHeight:(CGFloat)preferredRowHeight
{
    _preferredRowHeight = preferredRowHeight;
    
    [self invalidateLayout];
}

@end
