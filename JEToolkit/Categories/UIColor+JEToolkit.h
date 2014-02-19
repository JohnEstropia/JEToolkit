//
//  UIColor+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JECompilerDefines.h"


@interface UIColor (JEToolkit)

/*! Extracts a color from the given value.
 @param valueOrNil The object to extract date from. Accepts nil, UIColor, an NSNumber representation of an RGB value, an RGB-hex formatted NSString, or an NSArray of color float components
 @return valueOrNil if it is a UIColor, a color from an RGB NSNumber value, a color from a hex formatted NSString, a color from an NSArray of color components, or nil otherwise.
 */
+ (UIColor *)colorWithValue:(id)valueOrNil;

/*! Creates a color from a color hex string.
 @param hexString The RGB-hex formatted NSString to convert a color from
 @return A color from the hex formatted NSString
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString JE_NONNULL_ALL;

/*! Creates a color from a RGB integer value.
 @param RGBInt The RGB integer value to convert from
 @param alpha The extracted color's alpha value
 @return a color from the RGB integer
 */
+ (UIColor *)colorWithInt:(NSUInteger)RGBInt alpha:(CGFloat)alpha;

/*! Creates a color from an array of float color components.
 @param components The array of float color components. Accepts 1 to 4 components.
 @return a color from the color components
 */
+ (UIColor *)colorWithComponents:(NSArray *)components JE_NONNULL_ALL;

/*! Creates a random color.
 @return a random opaque color
 */
+ (UIColor *)randomColor;

@end
