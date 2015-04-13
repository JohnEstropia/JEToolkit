//
//  UIScrollView+JEToolkit.m
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

#import "UIScrollView+JEToolkit.h"

#import "NSObject+JEToolkit.h"
#import "UIView+JEToolkit.h"

#import "JESafetyHelpers.h"


@implementation UIScrollView (JEToolkit)

#pragma mark - Public

- (void)addKeyboardObserver {
    
	CGFloat originalContentInsetBottom = self.contentInset.bottom;
	CGFloat originalScrollInsetBottom = self.scrollIndicatorInsets.bottom;
	
    JEScopeWeak(self);
    [self
     registerForNotificationsWithName:UIKeyboardWillShowNotification
     targetBlock:^(NSNotification *note) {
         
         JEScopeStrong(self);
         if (!self) {
             
             return;
         }
         
         NSDictionary *userInfo = [note userInfo];
         CGRect keyboardFrameInScrollView = [self convertRect:[(NSValue *)userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
         CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
         UIViewAnimationOptions animationCurve = kNilOptions;
         switch ([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]) {
                 
             case UIViewAnimationCurveEaseInOut:
                 animationCurve = UIViewAnimationOptionCurveEaseInOut;
                 break;
             case UIViewAnimationCurveEaseIn:
                 animationCurve = UIViewAnimationOptionCurveEaseIn;
                 break;
             case UIViewAnimationCurveEaseOut:
                 animationCurve = UIViewAnimationOptionCurveEaseOut;
                 break;
             case UIViewAnimationCurveLinear:
                 animationCurve = UIViewAnimationOptionCurveLinear;
                 break;
         }
         
         CGFloat coveredHeight = (CGRectGetMaxY(self.bounds)
                                  - CGRectGetMinY(keyboardFrameInScrollView));
         
         UIEdgeInsets contentInsets = self.contentInset;
         contentInsets.bottom = (coveredHeight
                                 + originalContentInsetBottom);
         
         UIEdgeInsets scrollInsets = self.scrollIndicatorInsets;
         scrollInsets.bottom = (coveredHeight
                                + originalScrollInsetBottom);
         
         UIView *firstResponder = [self findFirstResponder];
         CGRect textViewFrameInScrollView = [self
                                             convertRect:firstResponder.bounds
                                             fromView:firstResponder];
         
         [UIView
          animateWithDuration:duration
          delay:0.0f
          options:(UIViewAnimationOptionBeginFromCurrentState | (animationCurve << 16))
          animations:^{
              
              self.contentInset = contentInsets;
              self.scrollIndicatorInsets = scrollInsets;
              if (firstResponder) {
                  
                  [self scrollRectToVisible:textViewFrameInScrollView animated:NO];
              }
              
          }
          completion:NULL];
         
     }];
    
    [self
     registerForNotificationsWithName:UIKeyboardWillHideNotification
     targetBlock:^(NSNotification *note) {
         
         JEScopeStrong(self);
         if (!self) {
             
             return;
         }
         
         NSDictionary *userInfo = [note userInfo];
         CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
         UIViewAnimationOptions animationCurve = kNilOptions;
         switch ([userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]) {
                 
             case UIViewAnimationCurveEaseInOut:
                 animationCurve = UIViewAnimationOptionCurveEaseInOut;
                 break;
             case UIViewAnimationCurveEaseIn:
                 animationCurve = UIViewAnimationOptionCurveEaseIn;
                 break;
             case UIViewAnimationCurveEaseOut:
                 animationCurve = UIViewAnimationOptionCurveEaseOut;
                 break;
             case UIViewAnimationCurveLinear:
                 animationCurve = UIViewAnimationOptionCurveLinear;
                 break;
         }
         
         UIEdgeInsets contentInsets = self.contentInset;
         contentInsets.bottom = originalContentInsetBottom;
         
         UIEdgeInsets scrollInsets = self.scrollIndicatorInsets;
         scrollInsets.bottom = originalScrollInsetBottom;
         
         [UIView
          animateWithDuration:duration
          delay:0.0f
          options:(UIViewAnimationOptionBeginFromCurrentState | (animationCurve << 16))
          animations:^{
              
              self.contentInset = contentInsets;
              self.scrollIndicatorInsets = scrollInsets;
              
          }
          completion:NULL];
         
     }];
}

- (void)removeKeyboardObserver {
    
    [self unregisterForNotificationsWithName:UIKeyboardWillShowNotification];
    [self unregisterForNotificationsWithName:UIKeyboardWillHideNotification];
}

- (void)scrollToTopAnimated:(BOOL)animated {
    
    CGRect bounds = self.bounds;
    CGRect rect = (CGRect){
        .origin.x = CGRectGetMinX(bounds),
        .origin.y = -self.contentInset.top,
        .size = bounds.size
    };
    if (animated) {
        
        [UIView
         animateWithDuration:0.25
         delay:0
         options:(UIViewAnimationOptionBeginFromCurrentState
                  | UIViewAnimationOptionAllowUserInteraction)
         animations:^{
             
             [self scrollRectToVisible:rect animated:NO];
         }
         completion:nil];
    }
    else {
        
        [self scrollRectToVisible:rect animated:NO];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    
    CGRect bounds = self.bounds;
    CGFloat boundsHeight = CGRectGetHeight(bounds);
    CGRect rect = (CGRect){
        .origin.x = CGRectGetMinX(bounds),
        .origin.y = (self.contentSize.height - boundsHeight),
        .size.width = CGRectGetWidth(bounds),
        .size.height = boundsHeight
    };
    if (animated) {
        
        [UIView
         animateWithDuration:0.25
         delay:0
         options:(UIViewAnimationOptionBeginFromCurrentState
                  | UIViewAnimationOptionAllowUserInteraction)
         animations:^{
             
             [self scrollRectToVisible:rect animated:NO];
         }
         completion:nil];
    }
    else {
        
        [self scrollRectToVisible:rect animated:NO];
    }
}

@end
