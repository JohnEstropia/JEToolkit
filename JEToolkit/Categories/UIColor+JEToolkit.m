//
//  UIColor+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "UIColor+JEToolkit.h"

#import "JEDebugging.h"


@implementation UIColor (JEToolkit)

//#pragma mark - NSObject
//
//- (NSString *)debugDescription
//{
//    return [super debugDescription];
//}
//
//
//#pragma mark - NSObject+JEToolkit

//- (NSUInteger)RGBCodeAndAlpha:(CGFloat *)alpha
//{
//    CGFloat redFloat = 0.0f;
//    CGFloat greenFloat = 0.0f;
//    CGFloat blueFloat = 0.0f;
//    CGFloat alphaFloat = 0.0f;
//    
//    if (![self getRed:&redFloat green:&greenFloat blue:&blueFloat alpha:&alphaFloat])
//    {
//        CGColorRef CGColor = self.CGColor;
//        CGColorSpaceRef colorSpace = CGColorGetColorSpace(CGColor);
//        const CGFloat *colorComponents = CGColorGetComponents(CGColor);
//        
//        switch (CGColorSpaceGetModel(colorSpace))
//        {
//            case kCGColorSpaceModelMonochrome:
//                NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 2);
//                redFloat = colorComponents[0];
//                greenFloat = colorComponents[0];
//                blueFloat = colorComponents[0];
//                alphaFloat = colorComponents[1];
//                break;
//            case kCGColorSpaceModelRGB:
//                NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 4);
//                redFloat = colorComponents[0];
//                greenFloat = colorComponents[1];
//                blueFloat = colorComponents[2];
//                alphaFloat = colorComponents[3];
//                break;
//            case kCGColorSpaceModelCMYK:
//                NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 5);
//                redFloat = (1.0f - (colorComponents[0]
//                                    - (colorComponents[0] * colorComponents[3])
//                                    + colorComponents[3]));
//                greenFloat = (1.0f - (colorComponents[1]
//                                      - (colorComponents[1] * colorComponents[3])
//                                      + colorComponents[3]));
//                blueFloat = (1.0f - (colorComponents[2]
//                                     - (colorComponents[2] * colorComponents[3])
//                                     + colorComponents[3]));
//                alphaFloat = colorComponents[4];
//                break;
//            default:
//                break;
//        }
//    }
//    
//    NSUInteger redInt = ceilf(redFloat * 255.0f);
//    NSUInteger greenInt = ceilf(greenFloat * 255.0f);
//    NSUInteger blueInt = ceilf(blueFloat * 255.0f);
//    
//    if (alpha)
//    {
//        (*alpha) = alphaFloat;
//    }
//    
//    return ((redInt << 16) | (greenInt << 8) | blueInt);
//}
//
//- (NSString *)loggingDescription
//{
//    CGFloat redFloat = 0.0f;
//    CGFloat greenFloat = 0.0f;
//    CGFloat blueFloat = 0.0f;
//    CGFloat alphaFloat = 0.0f;
//    NSString *colorSpaceString = [NSString string];
//    
//    CGColorRef CGColor = self.CGColor;
//    CGColorSpaceRef colorSpace = CGColorGetColorSpace(CGColor);
//    const CGFloat *colorComponents = CGColorGetComponents(CGColor);
//    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
//    switch (colorSpaceModel)
//    {
//        case kCGColorSpaceModelMonochrome:
//            NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 2);
//            redFloat = colorComponents[0];
//            greenFloat = colorComponents[0];
//            blueFloat = colorComponents[0];
//            alphaFloat = colorComponents[1];
//            colorSpaceString = @"kCGColorSpaceModelMonochrome";
//            break;
//        case kCGColorSpaceModelRGB:
//            NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 4);
//            redFloat = colorComponents[0];
//            greenFloat = colorComponents[1];
//            blueFloat = colorComponents[2];
//            alphaFloat = colorComponents[3];
//            colorSpaceString = @"kCGColorSpaceModelRGB";
//            break;
//        case kCGColorSpaceModelCMYK:
//            NSCParameterAssert(CGColorGetNumberOfComponents(CGColor) >= 5);
//            redFloat = (1.0f - (colorComponents[0]
//                                - (colorComponents[0] * colorComponents[3])
//                                + colorComponents[3]));
//            greenFloat = (1.0f - (colorComponents[1]
//                                  - (colorComponents[1] * colorComponents[3])
//                                  + colorComponents[3]));
//            blueFloat = (1.0f - (colorComponents[2]
//                                 - (colorComponents[2] * colorComponents[3])
//                                 + colorComponents[3]));
//            alphaFloat = colorComponents[4];
//            colorSpaceString = @"kCGColorSpaceModelCMYK";
//            break;
//        case kCGColorSpaceModelLab:
//            colorSpaceString = @"kCGColorSpaceModelLab";
//            break;
//        case kCGColorSpaceModelDeviceN:
//            colorSpaceString = @"kCGColorSpaceModelDeviceN";
//            break;
//        case kCGColorSpaceModelIndexed:
//            colorSpaceString = @"kCGColorSpaceModelIndexed";
//            break;
//        case kCGColorSpaceModelPattern:
//            colorSpaceString = @"kCGColorSpaceModelPattern";
//            break;
//        case kCGColorSpaceModelUnknown:
//            colorSpaceString = @"kCGColorSpaceModelUnknown";
//            break;
//        default:
//            break;
//    }
//    
//    NSUInteger redInt = ceilf(redFloat * 255.0f);
//    NSUInteger greenInt = ceilf(greenFloat * 255.0f);
//    NSUInteger blueInt = ceilf(blueFloat * 255.0f);
//    
//    NSMutableString *description = [NSMutableString stringWithFormat:
//                                    @"#%02X%02X%02X (%g%% alpha) {",
//                                    (unsigned int)redInt,
//                                    (unsigned int)greenInt,
//                                    (unsigned int)blueInt,
//                                    (alphaFloat * 100.0f)];
//    [description appendFormat:@"\ncolor space: %@", colorSpaceString];
//    if (colorSpaceModel == kCGColorSpaceModelMonochrome
//        || colorSpaceModel == kCGColorSpaceModelRGB
//        || colorSpaceModel == kCGColorSpaceModelCMYK)
//    {
//        [description appendFormat:
//         @",\nRGBA: (%u, %u, %u, %g)",
//         (unsigned int)redInt, (unsigned int)greenInt, (unsigned int)blueInt, alphaFloat];
//    }
//    if (colorSpaceModel == kCGColorSpaceModelCMYK)
//    {
//        [self getHue:<#(CGFloat *)#> saturation:<#(CGFloat *)#> brightness:<#(CGFloat *)#> alpha:<#(CGFloat *)#>]
//        [description appendFormat:
//         @",\nRGB: (%u, %u, %u)",
//         (unsigned int)redInt, (unsigned int)greenInt, (unsigned int)blueInt];
//    }
//    
//    return ((redInt << 16) | (greenInt << 8) | blueInt);
//    
//    kCGColorSpaceModelUnknown = -1,
//    kCGColorSpaceModelMonochrome,
//    kCGColorSpaceModelRGB,
//    kCGColorSpaceModelCMYK,
//    kCGColorSpaceModelLab,
//    kCGColorSpaceModelDeviceN,
//    kCGColorSpaceModelIndexed,
//    kCGColorSpaceModelPattern
//    
//    
//    CGSize size = self.size;
//    CGFloat scale = self.scale;
//    NSMutableString *description = [NSMutableString stringWithFormat:
//                                    @"(%gpt × %gpt @%gx) {",
//                                    size.width, size.height, scale];
//    [description appendFormat:
//     @"\npixel size: %gpx × %gpx",
//     (size.width * scale), (size.height * scale)];
//    
//    [description appendString:@"\norientation: "];
//    switch (self.imageOrientation)
//    {
//        case UIImageOrientationUp:
//            [description appendString:@"UIImageOrientationUp"];
//            break;
//        case UIImageOrientationDown:
//            [description appendString:@"UIImageOrientationDown"];
//            break;
//        case UIImageOrientationLeft:
//            [description appendString:@"UIImageOrientationLeft"];
//            break;
//        case UIImageOrientationRight:
//            [description appendString:@"UIImageOrientationRight"];
//            break;
//        case UIImageOrientationUpMirrored:
//            [description appendString:@"UIImageOrientationUpMirrored"];
//            break;
//        case UIImageOrientationDownMirrored:
//            [description appendString:@"UIImageOrientationDownMirrored"];
//            break;
//        case UIImageOrientationLeftMirrored:
//            [description appendString:@"UIImageOrientationLeftMirrored"];
//            break;
//        case UIImageOrientationRightMirrored:
//            [description appendString:@"UIImageOrientationRightMirrored"];
//            break;
//        default:
//            [description appendFormat:@"%li", (long)self.imageOrientation];
//            break;
//    }
//    
//    [description appendString:@"\nresizing mode: "];
//    switch (self.resizingMode)
//    {
//        case UIImageResizingModeTile:
//            [description appendString:@"UIImageResizingModeTile"];
//            break;
//        case UIImageResizingModeStretch:
//            [description appendString:@"UIImageResizingModeStretch"];
//            break;
//        default:
//            [description appendFormat:@"%li", (long)self.resizingMode];
//            break;
//    }
//    
//    UIEdgeInsets capInsets = self.capInsets;
//    [description appendFormat:
//     @"\nend-cap insets: { top:%gpt, left:%gpt, bottom:%gpt, right:%gpt }",
//     capInsets.top, capInsets.left, capInsets.bottom, capInsets.right];
//    
//    NSArray *images = self.images;
//    if (images)
//    {
//        [description appendFormat:
//         @"\nanimation duration: %.3g seconds",
//         self.duration];
//        
//        [description appendString:@"\nanimation images: "];
//        [description appendString:[images loggingDescriptionIncludeClass:NO includeAddress:NO]];
//    }
//    
//    [description indentByLevel:1];
//    [description appendString:@"\n}"];
//    
//    return description;
//}


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
