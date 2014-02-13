//
//  BalancedFlowLayout.h
//  BalancedFlowLayout
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
 * Currently this class does not support supplementary or decoration views.
 *
 */
@interface NHBalancedFlowLayout : UICollectionViewFlowLayout

// The preferred size for each row measured in the scroll direction
@property (nonatomic) CGFloat preferredRowSize;


@end


@protocol NHBalancedFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(NHBalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end