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
    
    return [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)];
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
