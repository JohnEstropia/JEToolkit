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

- (CGSize)sizeForText {
    
    CGSize constrainSize = (CGSize){
        .width = CGRectGetWidth(self.bounds),
        .height = CGFLOAT_MAX
    };
    
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        
        return [self sizeThatFits:constrainSize];
    }
    
    return [self.text
            sizeWithFont:self.font
            constrainedToSize:constrainSize
            lineBreakMode:self.lineBreakMode];
}

- (CGSize)sizeForAttributedText {
    
    CGSize size = [self.attributedText
                   boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)
                   options:(NSStringDrawingUsesLineFragmentOrigin
                            | NSStringDrawingUsesFontLeading)
                   context:nil].size;
    return (CGSize){
        .width = ceilf(size.width),
        .height = ceilf(size.height)
    };
    
}

@end
