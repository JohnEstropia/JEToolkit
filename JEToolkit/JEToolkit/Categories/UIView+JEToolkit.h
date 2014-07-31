//
//  UIView+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JEToolkit)

#pragma mark - Geometry Helpers

/*! Shorthand for accessing and mutating frame.origin.x
 */
@property (nonatomic, assign) CGFloat frameOriginX;

/*! Shorthand for accessing and mutating frame.origin.y
 */
@property (nonatomic, assign) CGFloat frameOriginY;

/*! Shorthand for accessing and mutating frame.origin
 */
@property (nonatomic, assign) CGPoint frameOrigin;

/*! Shorthand for accessing and mutating frame.size.width
 */
@property (nonatomic, assign) CGFloat frameSizeWidth;

/*! Shorthand for accessing and mutating frame.size.height
 */
@property (nonatomic, assign) CGFloat frameSizeHeight;

/*! Shorthand for accessing and mutating frame.size
 */
@property (nonatomic, assign) CGSize frameSize;

/*! Shorthand for accessing and mutating bounds.origin.x
 */
@property (nonatomic, assign) CGFloat boundsOriginX;

/*! Shorthand for accessing and mutating bounds.origin.y
 */
@property (nonatomic, assign) CGFloat boundsOriginY;

/*! Shorthand for accessing and mutating bounds.origin
 */
@property (nonatomic, assign) CGPoint boundsOrigin;

/*! Shorthand for accessing and mutating bounds.size.width
 */
@property (nonatomic, assign) CGFloat boundsSizeWidth;

/*! Shorthand for accessing and mutating bounds.size.height
 */
@property (nonatomic, assign) CGFloat boundsSizeHeight;

/*! Shorthand for accessing and mutating bounds.size
 */
@property (nonatomic, assign) CGSize boundsSize;

/*! Shorthand for accessing and mutating center.x
 */
@property (nonatomic, assign) CGFloat centerX;

/*! Shorthand for accessing and mutating center.y
 */
@property (nonatomic, assign) CGFloat centerY;


#pragma mark - Hierarchy Helpers

/*! Returns the first view within the receiver's view tree that is the first responder
 */
- (UIView *)findFirstResponder;

/*! Returns the first subview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (id)firstSubviewWithClass:(Class)viewClass;

/*! Returns the first superview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (id)firstSuperviewWithClass:(Class)viewClass;

@end
