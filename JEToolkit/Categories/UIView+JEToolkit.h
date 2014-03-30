//
//  UIView+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JEToolkit)

@property (nonatomic, assign) CGFloat frameOriginX;
@property (nonatomic, assign) CGFloat frameOriginY;
@property (nonatomic, assign) CGPoint frameOrigin;
@property (nonatomic, assign) CGFloat frameSizeWidth;
@property (nonatomic, assign) CGFloat frameSizeHeight;
@property (nonatomic, assign) CGSize frameSize;

@property (nonatomic, assign) CGFloat boundsOriginX;
@property (nonatomic, assign) CGFloat boundsOriginY;
@property (nonatomic, assign) CGPoint boundsOrigin;
@property (nonatomic, assign) CGFloat boundsSizeWidth;
@property (nonatomic, assign) CGFloat boundsSizeHeight;
@property (nonatomic, assign) CGSize boundsSize;

@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;

/*! Returns the first view within the receiver's view tree that is the first responder
 */
- (UIView *)findFirstResponder;

/*! Returns the first subview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (id)firstSubviewWithClass:(Class)class;

/*! Returns the first superview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (id)firstSuperviewWithClass:(Class)class;

@end
