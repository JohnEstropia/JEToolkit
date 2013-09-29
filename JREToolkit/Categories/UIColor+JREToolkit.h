//
//  UIColor+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JREToolkitDefines.h"


@interface UIColor (JREToolkit)

+ (UIColor *)colorWithObject:(id)objectOrNil;

+ (UIColor *)colorWithHexString:(NSString *)hexString JRE_NONNULL_ALL;

+ (UIColor *)colorWithInt:(NSUInteger)RGBInt alpha:(CGFloat)alpha;

+ (UIColor *)colorWithComponents:(NSArray *)components JRE_NONNULL_ALL;


@end
