//
//  UIImage+JEDebugging.m
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

#import "UIImage+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation UIImage (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    // override any existing implementation
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
    CGSize size = self.size;
    CGFloat scale = self.scale;
    NSMutableString *description = [NSMutableString stringWithFormat:
                                    @"(%gpt × %gpt @%gx) {",
                                    size.width, size.height, scale];
    [description appendFormat:
     @"\npixel size: %gpx × %gpx",
     (size.width * scale), (size.height * scale)];
    
    [description appendString:@"\norientation: "];
    switch (self.imageOrientation) {
            
        case UIImageOrientationUp:
            [description appendString:@"UIImageOrientationUp"];
            break;
            
        case UIImageOrientationDown:
            [description appendString:@"UIImageOrientationDown"];
            break;
            
        case UIImageOrientationLeft:
            [description appendString:@"UIImageOrientationLeft"];
            break;
            
        case UIImageOrientationRight:
            [description appendString:@"UIImageOrientationRight"];
            break;
            
        case UIImageOrientationUpMirrored:
            [description appendString:@"UIImageOrientationUpMirrored"];
            break;
            
        case UIImageOrientationDownMirrored:
            [description appendString:@"UIImageOrientationDownMirrored"];
            break;
            
        case UIImageOrientationLeftMirrored:
            [description appendString:@"UIImageOrientationLeftMirrored"];
            break;
            
        case UIImageOrientationRightMirrored:
            [description appendString:@"UIImageOrientationRightMirrored"];
            break;
            
        default:
            [description appendFormat:@"%li", (long)self.imageOrientation];
            break;
    }
    
    [description appendString:@"\nresizing mode: "];
    switch (self.resizingMode) {
            
        case UIImageResizingModeTile:
            [description appendString:@"UIImageResizingModeTile"];
            break;
            
        case UIImageResizingModeStretch:
            [description appendString:@"UIImageResizingModeStretch"];
            break;
            
        default:
            [description appendFormat:@"%li", (long)self.resizingMode];
            break;
    }
    
    UIEdgeInsets capInsets = self.capInsets;
    [description appendFormat:
     @"\nend-cap insets: { top:%gpt, left:%gpt, bottom:%gpt, right:%gpt }",
     capInsets.top, capInsets.left, capInsets.bottom, capInsets.right];
    
    NSArray *images = self.images;
    if (images) {
        
        [description appendFormat:
         @"\nanimation duration: %.3g seconds",
         self.duration];
        
        [description appendString:@"\nanimation images: "];
        [description appendString:[images loggingDescriptionIncludeClass:NO includeAddress:NO]];
    }
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}


@end
