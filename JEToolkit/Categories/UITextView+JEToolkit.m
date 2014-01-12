//
//  UITextView+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/01/11.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "UITextView+JEToolkit.h"

@implementation UITextView (JEToolkit)

#pragma mark - Public

- (CGSize)sizeForText
{
    if ([self respondsToSelector:@selector(textContainerInset)])
    {
        UIEdgeInsets containerInset = self.textContainerInset;
        CGSize sizeThatFits = [self sizeThatFits:(CGSize){
            .width = self.contentSize.width,
            .height = CGFLOAT_MAX
        }];
        return (CGSize){
            .width = (sizeThatFits.width + ((containerInset.left + containerInset.right) * 0.5f)),
            .height = (sizeThatFits.height + ((containerInset.top + containerInset.bottom) * 0.5f))
        };
    }
    
    return self.contentSize;
}

@end
