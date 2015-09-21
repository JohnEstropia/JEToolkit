//
//  UIView+JEToolkit.m
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

#import "UIView+JEToolkit.h"
#import "NSObject+JEToolkit.h"
#import "UINib+JEToolkit.h"

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#endif


@implementation UIView (JEToolkit)

#pragma mark - Public

#pragma mark Geometry Helpers

- (CGFloat)frameOriginX {
    
    return self.frame.origin.x;
}

- (void)setFrameOriginX:(CGFloat)frameOriginX {
    
    CGRect frame = self.frame;
    frame.origin.x = frameOriginX;
    self.frame = frame;
}

- (CGFloat)frameOriginY {
    
    return self.frame.origin.y;
}

- (void)setFrameOriginY:(CGFloat)frameOriginY {
    
    CGRect frame = self.frame;
    frame.origin.y = frameOriginY;
    self.frame = frame;
}

- (CGPoint)frameOrigin {
    
    return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)frameOrigin {
    
    CGRect frame = self.frame;
    frame.origin = frameOrigin;
    self.frame = frame;
}

- (CGFloat)frameSizeWidth {
    
    return self.frame.size.width;
}

- (void)setFrameSizeWidth:(CGFloat)frameSizeWidth {
    
    CGRect frame = self.frame;
    frame.size.width = frameSizeWidth;
    self.frame = frame;
}

- (CGFloat)frameSizeHeight {
    
    return self.frame.size.height;
}

- (void)setFrameSizeHeight:(CGFloat)frameSizeHeight {
    
    CGRect frame = self.frame;
    frame.size.height = frameSizeHeight;
    self.frame = frame;
}

- (CGSize)frameSize {
    
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)frameSize {
    
    CGRect frame = self.frame;
    frame.size = frameSize;
    self.frame = frame;
}

- (CGFloat)boundsOriginX {
    
    return self.bounds.origin.x;
}

- (void)setBoundsOriginX:(CGFloat)boundsOriginX {
    
    CGRect bounds = self.bounds;
    bounds.origin.x = boundsOriginX;
    self.bounds = bounds;
}

- (CGFloat)boundsOriginY {
    
    return self.bounds.origin.y;
}

- (void)setBoundsOriginY:(CGFloat)boundsOriginY {
    
    CGRect bounds = self.bounds;
    bounds.origin.y = boundsOriginY;
    self.bounds = bounds;
}

- (CGPoint)boundsOrigin {
    
    return self.bounds.origin;
}

- (void)setBoundsOrigin:(CGPoint)boundsOrigin {
    
    CGRect bounds = self.bounds;
    bounds.origin = boundsOrigin;
    self.bounds = bounds;
}

- (CGFloat)boundsSizeWidth {
    
    return self.bounds.size.width;
}

- (void)setBoundsSizeWidth:(CGFloat)boundsSizeWidth {
    
    CGRect bounds = self.bounds;
    bounds.size.width = boundsSizeWidth;
    self.bounds = bounds;
}

- (CGFloat)boundsSizeHeight {
    
    return self.bounds.size.height;
}

- (void)setBoundsSizeHeight:(CGFloat)boundsSizeHeight {
    
    CGRect bounds = self.bounds;
    bounds.size.height = boundsSizeHeight;
    self.bounds = bounds;
}

- (CGSize)boundsSize {
    
    return self.bounds.size;
}

- (void)setBoundsSize:(CGSize)boundsSize {
    
    CGRect bounds = self.bounds;
    bounds.size = boundsSize;
    self.bounds = bounds;
}

- (CGFloat)centerX {
    
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY {
    
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

#pragma mark Factory

+ (instancetype)viewFromNib {
    
    NSString *className = [self classNameInAppModule];
    if(![UINib nibWithNameExists:className]) {
        
        return nil;
    }
    
    return [[[UINib cachedNibWithName:className] instantiateWithOwner:nil options:nil] firstObject];
}

#pragma mark Hierarchy Helpers

- (UIView *)findFirstResponder {
    
    if ([self isFirstResponder]) {
        
        return self;
    }
    
    for (UIView *subview in self.subviews) {
        
        UIView *firstResponder = [subview findFirstResponder];
        if (firstResponder) {
            
            return firstResponder;
        }
    }
    return nil;
}

- (__kindof UIView *)firstSubviewWithClass:(Class)viewClass {
    
    JEAssertParameter([viewClass isSubclassOfClass:[UIView class]]);
    
    if ([self isKindOfClass:viewClass]) {
        
        return self;
    }
    
    for (UIView *subview in self.subviews) {
        
        UIView *subviewWithClass = [subview firstSubviewWithClass:viewClass];
        if (subviewWithClass) {
            
            return subviewWithClass;
        }
    }
    
    return nil;
}

- (__kindof UIView *)firstSuperviewWithClass:(Class)viewClass {
    
    JEAssertParameter([viewClass isSubclassOfClass:[UIView class]]);
    
    if ([self isKindOfClass:viewClass]) {
        
        return self;
    }
    
    return [self.superview firstSuperviewWithClass:viewClass];
}

- (__kindof UIViewController *)findViewController {
    
    id nextResponder = [self nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        
        return nextResponder;
    }
    if ([nextResponder isKindOfClass:[UIView class]]) {
        
        return [(UIView *)nextResponder findViewController];
    }
    return nil;
}

@end
