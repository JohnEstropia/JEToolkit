//
//  UIColor+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "UIColor+JEToolkit.h"

@implementation UIColor (JEToolkit)

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
    NSCParameterAssert([hexString isKindOfClass:[NSString class]]);
    
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
        case 6: return [self colorWithInt:(NSUInteger)hexInt alpha:1.0f];
        case 8: return [self colorWithInt:(NSUInteger)(hexInt >> 8) alpha:(((CGFloat)(hexInt & 0xFF)) / 255.0f)];
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
    NSCParameterAssert([components isKindOfClass:[NSArray class]]);
    
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
