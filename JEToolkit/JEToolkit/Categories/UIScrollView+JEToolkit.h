//
//  UIScrollView+JEToolkit.h
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

#import <UIKit/UIKit.h>

@interface UIScrollView (JEToolkit)

/*! Lets the receiver respond to keyboard changes. 
 When the keyboard appears, the receiver automatically adjust its bottom content inset and scroll inset.
 If the UIResponder that activated the keyboard belongs to its view tree, the receiver also scrolls to display that subview just above the keyboard.
 */
- (void)addKeyboardObserver;

/*! Stops the receiver from handling keyboard changes.
 */
- (void)removeKeyboardObserver;

/*! Scrolls the receiver to the top.
 */
- (void)scrollToTopAnimated:(BOOL)animated;

/*! Scrolls the receiver to the bottom.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

@end
