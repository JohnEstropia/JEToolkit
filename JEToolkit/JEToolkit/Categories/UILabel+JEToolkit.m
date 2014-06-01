//
//  UILabel+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/01/11.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "UILabel+JEToolkit.h"

@implementation UILabel (JEToolkit)

#pragma mark - Public

- (CGSize)sizeForText
{
    CGFloat boundsWidth = self.bounds.size.width;
    CGSize constainSize = (CGSize){
        .width = boundsWidth,
        .height = CGFLOAT_MAX
    };
    
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        return [self sizeThatFits:constainSize];
    }
    
    return [self.text
            sizeWithFont:self.font
            constrainedToSize:constainSize
            lineBreakMode:self.lineBreakMode];
}

@end