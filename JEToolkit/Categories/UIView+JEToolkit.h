//
//  UIView+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JEToolkit)

/*! Returns the first subview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (id)firstSubviewWithClass:(Class)class;

/*! Returns the first superview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (id)firstSuperviewWithClass:(Class)class;

@end
