//
//  UIView+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "UIView+JREToolkit.h"

@implementation UIView (JREToolkit)

#pragma mark - public

- (id)firstSubviewWithClass:(Class)class
{
    NSCParameterAssert([class isSubclassOfClass:[UIView class]]);
    
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
    NSCParameterAssert([class isSubclassOfClass:[UIView class]]);
    
    if ([self isKindOfClass:class])
    {
        return self;
    }
    
    return [self.superview firstSuperviewWithClass:class];
}


@end
