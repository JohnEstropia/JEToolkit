//
//  UIViewController+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (JEToolkit)

/*! Checks if the receiver's view currently is in a window (i.e. currently in the view heirarchy)
 */
- (BOOL)hasWindow;

/*! Returns the recursive presentedViewController of the receiver
 */
- (UIViewController *)topmostPresentedViewController;

/*! Returns the recursive parentViewController of the receiver
 */
- (UIViewController *)rootParentViewController;

@end
