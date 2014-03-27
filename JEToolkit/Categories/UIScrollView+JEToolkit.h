//
//  UIScrollView+JEToolkit.h
//  JEToolkit
//
//  Created by DIT John Estropia on 2014/03/26.
//  Copyright (c) 2014年 John Rommel Estropia. All rights reserved.
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

@end
