//
//  UIImage+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/02/20.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "UIImage+JREToolkit.h"

@implementation UIImage (JREToolkit)

#pragma mark - public

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size
{
	CGRect rect = (CGRect){ .origin = CGPointZero, .size = size };
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];
	CGContextFillRect(context, rect);
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return image;
}

@end
