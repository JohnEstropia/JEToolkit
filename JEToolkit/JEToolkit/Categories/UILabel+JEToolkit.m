//
//  UILabel+JEToolkit.m
//  JEToolkit
//
//  Copyright (c) 2014 John Rommel Estropia
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

#import "UILabel+JEToolkit.h"

#import "JECompilerDefines.h"


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
    
    JE_PRAGMA_PUSH
    JE_PRAGMA_IGNORE("-Wdeprecated-declarations")
    return [self.text
            sizeWithFont:self.font
            constrainedToSize:constrainSize
            lineBreakMode:self.lineBreakMode];
    JE_PRAGMA_POP
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
