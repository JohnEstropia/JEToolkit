//
//  UIViewController+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "UIViewController+JREToolkit.h"

@implementation UIViewController (JREToolkit)

#pragma mark - public

- (BOOL)hasWindow
{
    return ([self isViewLoaded] && self.view.window != nil);
}

- (UIViewController *)topmostPresentedViewController
{
    UIViewController *presentedViewController = self.presentedViewController;
    if (presentedViewController)
    {
        return [presentedViewController topmostPresentedViewController];
    }
    return self;
}

- (UIViewController *)rootParentViewController
{
    UIViewController *parentViewController = self.parentViewController;
    if (parentViewController)
    {
        return [parentViewController rootParentViewController];
    }
    return self;
}


@end
