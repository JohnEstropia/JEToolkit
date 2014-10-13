//
//  UITextView+JEToolkit.m
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

#import "UITextView+JEToolkit.h"

@implementation UITextView (JEToolkit)

#pragma mark - Public

- (CGSize)sizeForText {
    
    CGSize contentSize = self.contentSize;
    if ([self respondsToSelector:@selector(textContainerInset)]) {
        
        UIEdgeInsets containerInset = self.textContainerInset;
        CGSize sizeThatFits = [self sizeThatFits:(CGSize){
            .width = contentSize.width,
            .height = CGFLOAT_MAX
        }];
        return (CGSize){
            .width = (sizeThatFits.width + ((containerInset.left + containerInset.right) * 0.5f)),
            .height = (sizeThatFits.height + ((containerInset.top + containerInset.bottom) * 0.5f))
        };
    }
    
    return contentSize;
}

@end
