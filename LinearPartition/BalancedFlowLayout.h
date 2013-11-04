//
//  BalancedFlowLayout.h
//  LinearPartition
//
//  Created by Niels de Hoog on 31/10/13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * The BalancedFlowLayout class is designed to display items of different sizes and aspect ratios in a grid, without wasting any visual space. 
 * It takes the preferred sizes for the displayed items and a preferred row height as input to determine the optimal layout.
 *
 * In order to use this layout, the delegate for the collection view must implement the required methods in the BalancedFlowLayoutDelegate protocol.
 *
 */
@interface BalancedFlowLayout : UICollectionViewLayout

// The preferred height for each row in the grid.
@property (nonatomic) CGFloat preferredRowHeight;

// The margins used to lay out content in a section.
@property (nonatomic) UIEdgeInsets sectionInset;

// The minimum spacing to use between lines of items in the grid.
@property (nonatomic) CGFloat minimumLineSpacing;

// The minimum spacing to use between items in the same row.
@property (nonatomic) CGFloat minimumInteritemSpacing;

@end


@protocol BalancedFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(BalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end