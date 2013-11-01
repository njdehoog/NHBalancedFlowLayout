//
//  BalancedFlowLayout.h
//  LinearPartition
//
//  Created by Niels de Hoog on 31/10/13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BalancedFlowLayout : UICollectionViewFlowLayout

// TODO: implement this
@property (nonatomic) CGFloat preferredRowHeight;

- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol BalancedFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>

@required
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(BalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end