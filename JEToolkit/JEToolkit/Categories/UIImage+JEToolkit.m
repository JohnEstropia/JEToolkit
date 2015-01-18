//
//  UIImage+JEToolkit.m
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

#import "UIImage+JEToolkit.h"


@implementation UIImage (JEToolkit)

#pragma mark - Public

+ (instancetype)imageFromFile:(NSString *)filePath
                        scale:(CGFloat)scale
                  orientation:(UIImageOrientation)orientation {
    
    NSParameterAssert(filePath);
    NSParameterAssert(scale > 0.0f);
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    UIImage *image = [[self alloc] initWithData:data scale:scale];
    if (image.imageOrientation != orientation) {
        
        image = [[self alloc] initWithCGImage:image.CGImage
                                        scale:scale
                                  orientation:orientation];
    }
    return image;
}

+ (UIImage *)imageFromColor:(UIColor *)color size:(CGSize)size {
    
	CGRect rect = (CGRect){ .origin = CGPointZero, .size = size };
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    [color setFill];
	CGContextFillRect(context, rect);
    
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return image;
}

+ (UIImage *)screenshot {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        
        imageSize = (CGSize){
            .width = imageSize.height,
            .height = imageSize.width
        };
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        
        CGRect windowBounds = window.bounds;
        CGContextSaveGState(context);
        CGContextTranslateCTM(context,
                              window.center.x,
                              window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context,
                              (-windowBounds.size.width * window.layer.anchorPoint.x),
                              (-windowBounds.size.height * window.layer.anchorPoint.y));
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        }
        else if (orientation == UIInterfaceOrientationLandscapeRight) {
            
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        }
        else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            
            [window drawViewHierarchyInRect:windowBounds afterScreenUpdates:YES];
        }
        else {
            
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)imageByTintingWithColor:(UIColor *)tintColor {
    
    CGSize size = self.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGRect drawRect = (CGRect){ .size = size };
    [self drawInRect:drawRect];
    
    [tintColor setFill];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceAtop);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.capInsets, image.capInsets)
        || self.resizingMode != image.resizingMode) {
        
        image = [image
                 resizableImageWithCapInsets:self.capInsets
                 resizingMode:self.resizingMode];
    }
    
    return image;
}

- (UIImage *)imageByFillingWithColor:(UIColor *)fillColor {
    
    CGSize size = self.size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    
    CGRect drawRect = (CGRect){ .size = size };
    [self drawInRect:drawRect];
    
    [fillColor setFill];
    UIRectFillUsingBlendMode(drawRect, kCGBlendModeSourceIn);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.capInsets, image.capInsets)
        || self.resizingMode != image.resizingMode) {
        
        image = [image
                 resizableImageWithCapInsets:self.capInsets
                 resizingMode:self.resizingMode];
    }
    
    return image;
}

- (instancetype)decodedImage {
    
    CGImageRef CGImage = self.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(CGImage), CGImageGetHeight(CGImage));
    CGRect imageRect = (CGRect){ .size = imageSize };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(CGImage);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone
                        || infoMask == kCGImageAlphaNoneSkipFirst
                        || infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone
        && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha
             && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(CGImage),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        
        return self;
    }
    
    CGContextDrawImage(context, imageRect, CGImage);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [[self class]
                                  imageWithCGImage:decompressedImageRef
                                  scale:self.scale
                                  orientation:self.imageOrientation];
    CGImageRelease(decompressedImageRef);
    
    return decompressedImage;
}


@end
