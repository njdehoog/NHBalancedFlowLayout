//
//  UIImage+Decompression.h
//  LinearPartition
//
//  Created by Niels de Hoog on 30/10/13.
//  Copyright (c) 2013 Niels de Hoog. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Decompresses an image so it can be displayed without lag.
 * Based on: http://ioscodesnippet.com/2011/10/02/force-decompressing-uiimage-in-background-to-achieve/
 */
@interface UIImage (Decompression)

+ (UIImage *)decodedImageWithImage:(UIImage *)image;

@end
