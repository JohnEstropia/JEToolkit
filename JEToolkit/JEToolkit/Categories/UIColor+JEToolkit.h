//
//  UIColor+JEToolkit.h
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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

/*! Creates a color by alpha blending another color.
 @param tintColor the color to apply as tint.
 @return a tinted color
 */
- (UIColor *)colorByTintingWithColor:(UIColor *)tintColor JE_NONNULL_ALL;

@end
