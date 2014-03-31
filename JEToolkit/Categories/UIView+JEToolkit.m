//
//  UIView+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "UIView+JEToolkit.h"

#import "JEDebugging.h"


@implementation UIView (JEToolkit)

#pragma mark - Public

- (CGFloat)frameOriginX
{
    return self.frame.origin.x;
}

- (void)setFrameOriginX:(CGFloat)frameOriginX
{
    CGRect frame = self.frame;
    frame.origin.x = frameOriginX;
    self.frame = frame;
}

- (CGFloat)frameOriginY
{
    return self.frame.origin.y;
}

- (void)setFrameOriginY:(CGFloat)frameOriginY
{
    CGRect frame = self.frame;
    frame.origin.y = frameOriginY;
    self.frame = frame;
}

- (CGPoint)frameOrigin
{
    return self.frame.origin;
}

- (void)setFrameOrigin:(CGPoint)frameOrigin
{
    CGRect frame = self.frame;
    frame.origin = frameOrigin;
    self.frame = frame;
}

- (CGFloat)frameSizeWidth
{
    return self.frame.size.width;
}

- (void)setFrameSizeWidth:(CGFloat)frameSizeWidth
{
    CGRect frame = self.frame;
    frame.size.width = frameSizeWidth;
    self.frame = frame;
}

- (CGFloat)frameSizeHeight
{
    return self.frame.size.height;
}

- (void)setFrameSizeHeight:(CGFloat)frameSizeHeight
{
    CGRect frame = self.frame;
    frame.size.height = frameSizeHeight;
    self.frame = frame;
}

- (CGSize)frameSize
{
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)frameSize
{
    CGRect frame = self.frame;
    frame.size = frameSize;
    self.frame = frame;
}

- (CGFloat)boundsOriginX
{
    return self.bounds.origin.x;
}

- (void)setBoundsOriginX:(CGFloat)boundsOriginX
{
    CGRect bounds = self.bounds;
    bounds.origin.x = boundsOriginX;
    self.bounds = bounds;
}

- (CGFloat)boundsOriginY
{
    return self.bounds.origin.y;
}

- (void)setBoundsOriginY:(CGFloat)boundsOriginY
{
    CGRect bounds = self.bounds;
    bounds.origin.y = boundsOriginY;
    self.bounds = bounds;
}

- (CGPoint)boundsOrigin
{
    return self.bounds.origin;
}

- (void)setBoundsOrigin:(CGPoint)boundsOrigin
{
    CGRect bounds = self.bounds;
    bounds.origin = boundsOrigin;
    self.bounds = bounds;
}

- (CGFloat)boundsSizeWidth
{
    return self.bounds.size.width;
}

- (void)setBoundsSizeWidth:(CGFloat)boundsSizeWidth
{
    CGRect bounds = self.bounds;
    bounds.size.width = boundsSizeWidth;
    self.bounds = bounds;
}

- (CGFloat)boundsSizeHeight
{
    return self.bounds.size.height;
}

- (void)setBoundsSizeHeight:(CGFloat)boundsSizeHeight
{
    CGRect bounds = self.bounds;
    bounds.size.height = boundsSizeHeight;
    self.bounds = bounds;
}

- (CGSize)boundsSize
{
    return self.bounds.size;
}

- (void)setBoundsSize:(CGSize)boundsSize
{
    CGRect bounds = self.bounds;
    bounds.size = boundsSize;
    self.bounds = bounds;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (UIView *)findFirstResponder
{
    if ([self isFirstResponder])
    {
        return self;
    }
    
    for (UIView *subview in self.subviews)
    {
        UIView *firstResponder = [subview findFirstResponder];
        if (firstResponder)
        {
            return firstResponder;
        }
    }
    return nil;
}

- (id)firstSubviewWithClass:(Class)class
{
    JEParameterAssert([class isSubclassOfClass:[UIView class]]);
    
    if ([self isKindOfClass:class])
    {
        return self;
    }
    
    for (UIView *subview in self.subviews)
    {
        UIView *subviewWithClass = [subview firstSubviewWithClass:class];
        if (subviewWithClass)
        {
            return subviewWithClass;
        }
    }
    
    return nil;
}

- (id)firstSuperviewWithClass:(Class)class
{
    JEParameterAssert([class isSubclassOfClass:[UIView class]]);
    
    if ([self isKindOfClass:class])
    {
        return self;
    }
    
    return [self.superview firstSuperviewWithClass:class];
}


@end
