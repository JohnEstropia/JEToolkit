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

/*! Creates a UIImage filled with the specified color
 @param color The color to fill the image
 @param size The size of the image
 @return A UIImage filled with the specified color and size
 */
+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size JRE_NONNULL(1);

@end
