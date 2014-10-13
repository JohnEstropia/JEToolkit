//
//  UIColor+JEDebugging.m
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

#import "UIColor+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation UIColor (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    // override any existing implementation
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSUInteger)RGBCodeAndAlpha:(CGFloat *)alpha {
    
    CGFloat redFloat = 0.0f;
    CGFloat greenFloat = 0.0f;
    CGFloat blueFloat = 0.0f;
    CGFloat alphaFloat = 0.0f;
    
    if (![self getRed:&redFloat green:&greenFloat blue:&blueFloat alpha:&alphaFloat]) {
        
        CGColorRef CGColor = self.CGColor;
        CGColorSpaceRef colorSpace = CGColorGetColorSpace(CGColor);
        const CGFloat *colorComponents = CGColorGetComponents(CGColor);
        
        switch (CGColorSpaceGetModel(colorSpace)) {
                
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
    
    if (alpha) {
        
        (*alpha) = alphaFloat;
    }
    
    return ((redInt << 16) | (greenInt << 8) | blueInt);
}

- (NSString *)loggingDescription {
    
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
    switch (colorSpaceModel) {
            
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
    if ([self getWhite:&white alpha:&alpha]) {
        
        [description appendFormat:
         @",\ngrayscale: (%g%%, %.01f)",
         roundf(white * 100.0f), alpha];
    }
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        
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
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        
        [description appendFormat:
         @",\nHSBA: (%u°, %.01f, %.01f, %.01f)",
         (unsigned int)ceil(fmod(hue, 360.0)),
         saturation,
         brightness,
         alpha];
    }
    
    if (colorSpaceModel == kCGColorSpaceModelCMYK) {
        
        [description appendFormat:
         @",\nCMYKA: (%.01f, %.01f, %.01f, %.01f, %.01f)",
         cyan, magenta, yellow, black, alpha];
    }
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}


@end
