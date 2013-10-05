//
//  UIImage+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/02/20.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JREToolkitDefines.h"


@interface UIImage (JREToolkit)

/*! Convenience method for loading an image from file while providing a custom scale and orientation
 @param filePath The file path of an image
 @param scale The scale of the image
 @param orientation The orientation of the image
 @return A UIImage from file, or nil if loading failed
 */
+ (instancetype)imageFromFile:(NSString *)filePath
                        scale:(CGFloat)scale
                  orientation:(UIImageOrientation)orientation;

/*! Creates a UIImage filled with the specified color
 @param color The color to fill the image
 @param size The size of the image
 @return A UIImage filled with the specified color and size
 */
+ (UIImage *)imageFromColor:(UIColor *)color
                       size:(CGSize)size JRE_NONNULL(1);

/*! Creates a decoded UIImage from the receiver. This is usually used to preload an image to prevent slight lags in the UI
 */
- (instancetype)decodedImage;

@end
