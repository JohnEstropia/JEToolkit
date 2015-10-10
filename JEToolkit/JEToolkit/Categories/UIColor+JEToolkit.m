//
//  UIColor+JEToolkit.m
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

#import "UIColor+JEToolkit.h"

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#endif


@implementation UIColor (JEToolkit)

#pragma mark - Public

+ (UIColor *)colorWithValue:(id)valueOrNil {
    
    if (!valueOrNil) {
        
        return nil;
    }
    
    if ([valueOrNil isKindOfClass:[UIColor class]]) {
        
        return valueOrNil;
    }
    if ([valueOrNil isKindOfClass:[NSNumber class]]) {
        
        return [self colorWithInt:[(NSNumber *)valueOrNil unsignedIntegerValue] alpha:1.0f];
    }
    if ([valueOrNil isKindOfClass:[NSString class]]) {
        
        return [self colorWithHexString:valueOrNil];
    }
    if ([valueOrNil isKindOfClass:[NSArray class]]) {
        
        return [self colorWithComponents:valueOrNil];
    }
    
    return nil;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    
    JEAssertParameter([hexString isKindOfClass:[NSString class]]);
    
    for (NSString *prefix in @[@"0x", @"#", @"0X"]) {
        
        if ([hexString hasPrefix:prefix]) {
            
            hexString = [hexString substringFromIndex:[prefix length]];
            break;
        }
    }
    
    NSUInteger hexStringLength = [hexString length];
    if (hexStringLength != 6 && hexStringLength != 8) {
        
        return nil;
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:hexString];
    unsigned long long hexInt = 0;
    if (![scanner scanHexLongLong:&hexInt]) {
        
        return nil;
    }
    
    switch ([hexString length]) {
            
        case 6: return [self
                        colorWithInt:(NSUInteger)hexInt
                        alpha:1.0f];
        case 8: return [self
                        colorWithInt:(NSUInteger)(hexInt >> 8)
                        alpha:(((CGFloat)(hexInt & 0xFF)) / 255.0f)];
    }
    return nil;
}

+ (UIColor *)colorWithInt:(NSUInteger)RGBInt alpha:(CGFloat)alpha {
    
    return [UIColor
            colorWithRed:(((CGFloat)((RGBInt & 0xFF0000) >> 16)) / 255.0f)
            green:(((CGFloat)((RGBInt & 0xFF00) >> 8)) / 255.0f)
            blue:(((CGFloat)(RGBInt & 0xFF)) / 255.0f)
            alpha:alpha];
}

+ (UIColor *)colorWithPatternNamed:(NSString *)patternName {
    
    return [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
}

+ (UIColor *)colorWithComponents:(NSArray *)components {
    
    JEAssertParameter([components isKindOfClass:[NSArray class]]);
    
    NSUInteger numberOfComponents = [components count];
    if (numberOfComponents < 1 || numberOfComponents > 4) {
        
        return nil;
    }
    for (id component in components) {
        
        if (![component isKindOfClass:[NSNumber class]]) {
            
            return nil;
        }
    }
    
    switch (numberOfComponents) {
            
        case 1: return [UIColor
                        colorWithWhite:[components[0] floatValue]
                        alpha:1.0f];
        case 2: return [UIColor
                        colorWithWhite:[components[0] floatValue]
                        alpha:[components[1] floatValue]];
        case 3: return [UIColor
                        colorWithRed:[components[0] floatValue]
                        green:[components[1] floatValue]
                        blue:[components[2] floatValue]
                        alpha:1.0f];
        case 4: return [UIColor
                        colorWithRed:[components[0] floatValue]
                        green:[components[1] floatValue]
                        blue:[components[2] floatValue]
                        alpha:[components[3] floatValue]];
    }
    return nil;
}

+ (UIColor *)randomColor {
    
    return [UIColor colorWithInt:arc4random_uniform(0x01000000) alpha:1.0f];
}

- (UIColor *)colorByTintingWithColor:(UIColor *)tintColor {
    
    CGFloat originalRed = 0;
    CGFloat originalGreen = 0;
    CGFloat originalBlue = 0;
    CGFloat originalAlpha = 0;
    
    if (![self getRed:&originalRed green:&originalGreen blue:&originalBlue alpha:&originalAlpha]) {
        
        CGFloat white;
        if (![self getWhite:&white alpha:&originalAlpha]) {
            
            return self;
        }
        
        originalRed = white;
        originalGreen = white;
        originalBlue = white;
    }
    
    CGFloat tintRed = 0;
    CGFloat tintGreen = 0;
    CGFloat tintBlue = 0;
    CGFloat tintAlpha = 0;
    
    if (![tintColor getRed:&tintRed green:&tintGreen blue:&tintBlue alpha:&tintAlpha]) {
        
        CGFloat white;
        if (![tintColor getWhite:&white alpha:&tintAlpha]) {
            
            return self;
        }
        
        tintRed = white;
        tintGreen = white;
        tintBlue = white;
    }
    
    // http://en.wikipedia.org/wiki/Alpha_compositing
    
    CGFloat outAlpha = (tintAlpha + (originalAlpha * (1.0f - tintAlpha)));
    
    CGFloat (^blendSourceAtop)(CGFloat sourceColor, CGFloat sourceAlpha, CGFloat destinationColor, CGFloat destinationAlpha) = ^(CGFloat sourceColor, CGFloat sourceAlpha, CGFloat destinationColor, CGFloat destinationAlpha) {
        
        return (((sourceColor * sourceAlpha)
                 + ((destinationColor * destinationAlpha) * (1.0f - sourceAlpha)))
                / outAlpha);
    };
    
    return [UIColor
            colorWithRed:blendSourceAtop(tintRed, tintAlpha, originalRed, originalAlpha)
            green:blendSourceAtop(tintGreen, tintAlpha, originalGreen, originalAlpha)
            blue:blendSourceAtop(tintBlue, tintAlpha, originalBlue, originalAlpha)
            alpha:outAlpha];
}


@end
