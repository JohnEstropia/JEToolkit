//
//  UIViewController+JEToolkit.h
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
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

@interface UIViewController (JEToolkit)

/*! Initializes a `UIViewController` instance from a storyboard with the same name as the class name, and with a storyboard identifier same with the class name.
 */
+ (null_unspecified instancetype)viewControllerFromStoryboard;

/*! Initializes a `UIViewController` instance from a storyboard if an instance with the storyboard identifier same as the class name exists.
 */
+ (null_unspecified instancetype)viewControllerFromStoryboard:(nonnull UIStoryboard *)storyboard;

/*! Returns the recursive presentedViewController for the application
 */
+ (nullable __kindof UIViewController *)topmostPresentedViewController;

/*! Returns the candidate view controller for presenting a new modal controller
 */
+ (nonnull __kindof UIViewController *)topmostViewControllerInHierarchy;

/*! Checks if the receiver's view currently is in a window (i.e. currently in the view heirarchy)
 */
- (BOOL)hasWindow;

/*! Returns the recursive presentedViewController of the receiver
 */
- (nonnull __kindof UIViewController *)topmostPresentedViewController;

/*! Returns the recursive parentViewController of the receiver
 */
- (nonnull __kindof UIViewController *)rootParentViewController;

@end
