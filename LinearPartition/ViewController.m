//
//  ViewController.m
//  LinearPartition
//
//  Created by Niels de Hoog on 08-10-13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import "ViewController.h"
#import "ImageCell.h"
#import "LinearPartition.h"
#import "UIImage+Decompression.h"

#define NUMBER_OF_IMAGES 24

@interface ViewController ()

@property (nonatomic, strong) NSArray *images;

@property (nonatomic, strong) NSArray *itemSizes;

@end

@implementation ViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        for (int i = 1; i <= NUMBER_OF_IMAGES; i++) {
            NSString *imageName = [NSString stringWithFormat:@"photo-%02d.jpg", i];
            [images addObject:[UIImage imageNamed:imageName]];
        }
        _images = [images copy];
    }
    
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    CGFloat viewportWidth = CGRectGetWidth(self.view.bounds);
    CGFloat idealHeight = CGRectGetHeight(self.view.bounds) / 2.0;
    
    CGFloat totalImageWidth = 0;
    for (UIImage *image in self.images) {
        totalImageWidth += (image.size.width / image.size.height) * idealHeight;
    }
    
    NSInteger numberOfRows = roundf(totalImageWidth / viewportWidth);
    
    NSMutableArray *itemSizes = [NSMutableArray array];

    if (numberOfRows < 1) {
        for (UIImage *image in self.images) {
            CGSize itemSize = CGSizeMake(roundf((image.size.width / image.size.height) * idealHeight), roundf(idealHeight));
            [itemSizes addObject:[NSValue valueWithCGSize:itemSize]];
        }
    }
    else {
        NSMutableArray *weights = [NSMutableArray array];
        for (UIImage *image in self.images) {
            NSInteger aspectRatio = roundf((image.size.width / image.size.height) * 100);
            [weights addObject:@(aspectRatio)];
        }
        
        NSArray *partition = [LinearPartition linearPartitionForSequence:weights numberOfPartitions:numberOfRows];
        
        NSMutableArray *images = [self.images mutableCopy];
        NSMutableArray *newImages = [NSMutableArray array];
        for (NSArray *row in partition) {
            
            NSMutableArray *imagesInRow = [NSMutableArray array];
            
            for (NSNumber *weight in row) {
                
                UIImage *selectedImage = nil;
                for (UIImage *image in images) {
                    NSInteger aspectRatio = roundf((image.size.width / image.size.height) * 100);
                    if (aspectRatio == [weight integerValue]) {
                        selectedImage = image;
                        break;
                    }
                }
                
                [imagesInRow addObject:selectedImage];
                [images removeObject:selectedImage];
            }
            
            [newImages addObjectsFromArray:imagesInRow];
            
            CGFloat summedRatios = 0;
            for (UIImage *image in imagesInRow) {
                summedRatios += image.size.width / image.size.height;
            }
            
            for (UIImage *image in imagesInRow) {
                CGSize itemSize = CGSizeMake(roundf(viewportWidth / summedRatios * (image.size.width / image.size.height)), roundf(viewportWidth / summedRatios));
                [itemSizes addObject:[NSValue valueWithCGSize:itemSize]];
            }
        }
        
        self.images = [newImages copy];
    }
    
    self.itemSizes = [itemSizes copy];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.itemSizes objectAtIndex:indexPath.item] CGSizeValue];
}

#pragma mark - UICollectionView data source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [self.images count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    
    /**
     * Decompress image on background thread before displaying it to prevent lag
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *image = [UIImage decodedImageWithImage:[self.images objectAtIndex:indexPath.item]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = image;
        });
    });
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}


@end
