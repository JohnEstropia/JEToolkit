//
//  UIImage+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/02/20.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
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
