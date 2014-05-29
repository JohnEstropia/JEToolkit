//
//  UIColor+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "UIColor+JEToolkit.h"

#import "NSMutableString+JEToolkit.h"
#import "NSObject+JEToolkit.h"

#import "JEDebugging.h"


@implementation UIColor (JEToolkit)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [super debugDescription];
}


#pragma mark - NSObject+JEToolkit

- (NSUInteger)RGBCodeAndAlpha:(CGFloat *)alpha
{
    CGFloat redFloat = 0.0f;
    CGFloat greenFloat = 0.0f;
    CGFloat blueFloat = 0.0f;
    CGFloat alphaFloat = 0.0f;
    
    if (![self getRed:&redFloat green:&greenFloat blue:&blueFloat alpha:&alphaFloat])
    {
        CGColorRef CGColor = self.CGColor;
        CGColorSpaceRef colorSpace = CGColorGetColorSpace(CGColor);
        const CGFloat *colorComponents = CGColorGetComponents(CGColor);
        
        switch (CGColorSpaceGetModel(colorSpace))
        {
            case kCGColorSpaceModelMonochrome:
                NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 2);
                redFloat = colorComponents[0];
                greenFloat = colorComponents[0];
                blueFloat = colorComponents[0];
                alphaFloat = colorComponents[1];
                break;
            case kCGColorSpaceModelRGB:
                NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 4);
                redFloat = colorComponents[0];
                greenFloat = colorComponents[1];
                blueFloat = colorComponents[2];
                alphaFloat = colorComponents[3];
                break;
            case kCGColorSpaceModelCMYK:
                NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 5);
                redFloat = (1.0f - (colorComponents[0]
                                    - (colorComponents[0] * colorComponents[3])
                                    + colorComponents[3]));
                greenFloat = (1.0f - (colorComponents[1]
                                      - (colorComponents[1] * colorComponents[3])
                                      + colorComponents[3]));
                blueFloat = (1.0f - (colorComponents[2]
                                     - (colorComponents[2] * colorComponents[3])
                                     + colorComponents[3]));
                alphaFloat = colorComponents[4];
                break;
            default:
                break;
        }
    }
    
    NSUInteger redInt = ceilf(redFloat * 255.0f);
    NSUInteger greenInt = ceilf(greenFloat * 255.0f);
    NSUInteger blueInt = ceilf(blueFloat * 255.0f);
    
    if (alpha)
    {
        (*alpha) = alphaFloat;
    }
    
    return ((redInt << 16) | (greenInt << 8) | blueInt);
}

- (NSString *)loggingDescription
{
    CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat alpha = 0.0f;
    
    CGFloat cyan = 0.0f;
    CGFloat magenta = 0.0f;
    CGFloat yellow = 0.0f;
    CGFloat black = 0.0f;
    NSString *colorSpaceString;
    
    CGColorRef CGColor = self.CGColor;
    CGColorSpaceRef colorSpace = CGColorGetColorSpace(CGColor);
    const CGFloat *colorComponents = CGColorGetComponents(CGColor);
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    switch (colorSpaceModel)
    {
        case kCGColorSpaceModelMonochrome:
            NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 2);
            red = colorComponents[0];
            green = colorComponents[0];
            blue = colorComponents[0];
            alpha = colorComponents[1];
            colorSpaceString = @"kCGColorSpaceModelMonochrome";
            break;
        case kCGColorSpaceModelRGB:
            NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 4);
            red = colorComponents[0];
            green = colorComponents[1];
            blue = colorComponents[2];
            alpha = colorComponents[3];
            colorSpaceString = @"kCGColorSpaceModelRGB";
            break;
        case kCGColorSpaceModelCMYK:
            NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 5);
            cyan = colorComponents[0];
            magenta = colorComponents[1];
            yellow = colorComponents[2];
            black = colorComponents[3];
            alpha = colorComponents[4];
            red = (1.0f - (cyan - (cyan * black) + black));
            green = (1.0f - (magenta - (magenta * black) + black));
            blue = (1.0f - (yellow - (yellow * black) + black));
            colorSpaceString = @"kCGColorSpaceModelCMYK";
            break;
        case kCGColorSpaceModelLab:
            colorSpaceString = @"kCGColorSpaceModelLab";
            break;
        case kCGColorSpaceModelDeviceN:
            colorSpaceString = @"kCGColorSpaceModelDeviceN";
            break;
        case kCGColorSpaceModelIndexed:
            colorSpaceString = @"kCGColorSpaceModelIndexed";
            break;
        case kCGColorSpaceModelPattern:
            colorSpaceString = @"kCGColorSpaceModelPattern";
            break;
        case kCGColorSpaceModelUnknown:
            colorSpaceString = @"kCGColorSpaceModelUnknown";
            break;
        default:
            colorSpaceString = [NSString string];
            break;
    }
    
    NSMutableString *description = [NSMutableString stringWithFormat:
                                    @"#%02X%02X%02X (%g%% alpha) {",
                                    (unsigned int)ceilf(red * 255.0f),
                                    (unsigned int)ceilf(green * 255.0f),
                                    (unsigned int)ceilf(blue * 255.0f),
                                    (alpha * 100.0f)];
    [description appendFormat:@"\ncolor space: %@", colorSpaceString];
    
    CGFloat white = 0.0f;
    if ([self getWhite:&white alpha:&alpha])
    {
        [description appendFormat:
         @",\ngrayscale: (%g%%, %.01f)",
         roundf(white * 100.0f), alpha];
    }
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha])
    {
        [description appendFormat:
         @",\nRGBA: (%u, %u, %u, %.01f)",
         (unsigned int)ceilf(red * 255.0f),
         (unsigned int)ceilf(green * 255.0f),
         (unsigned int)ceilf(blue * 255.0f),
         alpha];
    }
    
    CGFloat hue = 0.0f;
    CGFloat saturation = 0.0f;
    CGFloat brightness = 0.0f;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha])
    {
        [description appendFormat:
         @",\nHSBA: (%u°, %.01f, %.01f, %.01f)",
         (unsigned int)ceil(fmod(hue, 360.0)),
         saturation,
         brightness,
         alpha];
    }
    
    if (colorSpaceModel == kCGColorSpaceModelCMYK)
    {
        [description appendFormat:
         @",\nCMYKA: (%.01f, %.01f, %.01f, %.01f, %.01f)",
         cyan, magenta, yellow, black, alpha];
    }
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}


#pragma mark - Public

+ (UIColor *)colorWithValue:(id)valueOrNil
{
    if (!valueOrNil)
    {
        return nil;
    }
    
    if ([valueOrNil isKindOfClass:[UIColor class]])
    {
        return valueOrNil;
    }
    if ([valueOrNil isKindOfClass:[NSNumber class]])
    {
        return [self colorWithInt:[(NSNumber *)valueOrNil unsignedIntegerValue] alpha:1.0f];
    }
    if ([valueOrNil isKindOfClass:[NSString class]])
    {
        return [self colorWithHexString:valueOrNil];
    }
    if ([valueOrNil isKindOfClass:[NSArray class]])
    {
        return [self colorWithComponents:valueOrNil];
    }
    
    return nil;
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    JEParameterAssert([hexString isKindOfClass:[NSString class]]);
    
    for (NSString *prefix in @[@"0x", @"#", @"0X"])
    {
        if ([hexString hasPrefix:prefix])
        {
            hexString = [hexString substringFromIndex:[prefix length]];
            break;
        }
    }
    
    NSUInteger hexStringLength = [hexString length];
    if (hexStringLength != 6 && hexStringLength != 8)
    {
        return nil;
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:hexString];
    unsigned long long hexInt = 0;
    if (![scanner scanHexLongLong:&hexInt])
    {
        return nil;
    }
    
    switch ([hexString length])
    {
        case 6: return [self
                        colorWithInt:(NSUInteger)hexInt
                        alpha:1.0f];
        case 8: return [self
                        colorWithInt:(NSUInteger)(hexInt >> 8)
                        alpha:(((CGFloat)(hexInt & 0xFF)) / 255.0f)];
    }
    return nil;
}

+ (UIColor *)colorWithInt:(NSUInteger)RGBInt alpha:(CGFloat)alpha
{
    return [UIColor
            colorWithRed:(((CGFloat)((RGBInt & 0xFF0000) >> 16)) / 255.0f)
            green:(((CGFloat)((RGBInt & 0xFF00) >> 8)) / 255.0f)
            blue:(((CGFloat)(RGBInt & 0xFF)) / 255.0f)
            alpha:alpha];
}

+ (UIColor *)colorWithComponents:(NSArray *)components
{
    JEParameterAssert([components isKindOfClass:[NSArray class]]);
    
    NSUInteger numberOfComponents = [components count];
    if (numberOfComponents < 1 || numberOfComponents > 4)
    {
        return nil;
    }
    for (id component in components)
    {
        if (![component isKindOfClass:[NSNumber class]])
        {
            return nil;
        }
    }
    
    switch (numberOfComponents)
    {
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

+ (UIColor *)randomColor
{
    return [UIColor colorWithInt:arc4random_uniform(0x01000000) alpha:1.0f];
}


@end
