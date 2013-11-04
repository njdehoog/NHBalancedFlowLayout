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

#pragma mark - Lifecycle

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
    self.minimumInteritemSpacing = 10;
}

#pragma mark - Layout

- (void)prepareLayout
{
    [super prepareLayout];
    
    NSAssert([self.delegate conformsToProtocol:@protocol(BalancedFlowLayoutDelegate)], @"UICollectionView delegate should conform to BalancedFlowLayout protocol");
    
    CGFloat idealHeight = self.preferredRowHeight > 0 ?: CGRectGetHeight(self.collectionView.bounds) / 3.0;
    
    CGFloat totalItemWidth = [self totalItemWidthForSection:0 preferredRowHeight:idealHeight];
    NSInteger numberOfRows = MAX(roundf(totalItemWidth / [self viewPortWidth]), 1);
    
    CGSize sectionSize = CGSizeZero;
    self.itemFrames = [self framesForItemsInSection:0 numberOfRows:numberOfRows sectionSize:&sectionSize];
    self.contentSize = sectionSize;
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

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Layout helpers

- (NSArray *)indexPathsForItemsInRect:(CGRect)rect
{
    // TODO: add support for sections
    NSMutableArray *indexPaths = [NSMutableArray array];

    
    for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
        if (CGRectIntersectsRect(rect, [[self.itemFrames objectAtIndex:i] CGRectValue])) {
            [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
        }
    }
    return [indexPaths copy];
}

- (CGFloat)totalItemWidthForSection:(NSInteger)section preferredRowHeight:(CGFloat)preferredRowHeight
{
    CGFloat totalItemWidth = 0;
    for (int i = 0, n = [self.collectionView numberOfItemsInSection:section]; i < n; i++) {
        CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section]];
        totalItemWidth += (preferredSize.width / preferredSize.height) * preferredRowHeight;
    }
    
    return totalItemWidth;
}

- (NSArray *)weightsForItemsInSection:(NSInteger)section
{
    NSMutableArray *weights = [NSMutableArray array];
    for (int i = 0, n = [self.collectionView numberOfItemsInSection:section]; i < n; i++) {
        CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section]];
        NSInteger aspectRatio = roundf((preferredSize.width / preferredSize.height) * 100);
        [weights addObject:@(aspectRatio)];
    }
    
    return [weights copy];
}

- (NSArray *)framesForItemsInSection:(NSInteger)section numberOfRows:(NSUInteger)numberOfRows sectionSize:(CGSize *)sectionSize
{
    NSMutableArray *itemFrames = [NSMutableArray array];

    NSArray *weights = [self weightsForItemsInSection:section];
    NSArray *partition = [LinearPartition linearPartitionForSequence:weights numberOfPartitions:numberOfRows];
    
    int i = 0;
    CGPoint offset = CGPointMake(self.sectionInset.left, self.sectionInset.top);
    CGFloat previousItemHeight = 0;
    CGFloat contentHeight = 0;
    for (NSArray *row in partition) {
        
        CGFloat summedRatios = 0;
        for (int j = i, n = i + [row count]; j < n; j++) {
            CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:section]];
            summedRatios += preferredSize.width / preferredSize.height;
        }
        
        NSInteger rowWidth = [self viewPortWidth] - (([row count] - 1) * self.minimumInteritemSpacing);
        for (int j = i, n = i + [row count]; j < n; j++) {
            CGSize preferredSize = [self.delegate collectionView:self.collectionView layout:self preferredSizeForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:section]];
            CGSize actualSize = CGSizeMake(roundf(rowWidth / summedRatios * (preferredSize.width / preferredSize.height)), roundf(rowWidth / summedRatios));
            
            CGRect frame = CGRectMake(offset.x, offset.y, actualSize.width, actualSize.height);
            [itemFrames addObject:[NSValue valueWithCGRect:frame]];
            
            offset.x += actualSize.width + self.minimumInteritemSpacing;
            previousItemHeight = actualSize.height;
            contentHeight = CGRectGetMaxY(frame);
        }
        
        // move offset to next line
        offset = CGPointMake(self.sectionInset.left, offset.y + previousItemHeight + self.minimumLineSpacing);
        
        i += [row count];
    }
    
    *sectionSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds), contentHeight + self.sectionInset.bottom);
    
    return [itemFrames copy];
}

- (CGFloat)viewPortWidth
{
    return CGRectGetWidth(self.collectionView.bounds) - self.sectionInset.left - self.sectionInset.right;
}

#pragma mark - Custom setters

- (void)setPreferredRowHeight:(CGFloat)preferredRowHeight
{
    _preferredRowHeight = preferredRowHeight;
    
    [self invalidateLayout];
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset
{
    _sectionInset = sectionInset;
    
    [self invalidateLayout];
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    _minimumLineSpacing = minimumLineSpacing;
    
    [self invalidateLayout];
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    _minimumInteritemSpacing = minimumInteritemSpacing;
    
    [self invalidateLayout];
}

#pragma mark - Delegate

- (id<BalancedFlowLayoutDelegate>)delegate
{
    return (id<BalancedFlowLayoutDelegate>)self.collectionView.delegate;
}

@end
