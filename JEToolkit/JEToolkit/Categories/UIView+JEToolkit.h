//
//  UIView+JEToolkit.h
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


#pragma mark - Factory

/*! Loads a view from nib. This assumes that the .nib file was named as the view's class name, and that the UIView is the first root object in the nib.
 */
+ (null_unspecified instancetype)viewFromNib;


#pragma mark - Hierarchy Helpers

/*! Returns the first view within the receiver's view tree that is the first responder
 */
- (nullable UIView *)findFirstResponder;

/*! Returns the first subview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (nullable __kindof UIView *)firstSubviewWithClass:(nonnull Class)viewClass;

/*! Returns the first superview that is a subclass of class. Searches recursively, and may return the receiver itself.
 */
- (nullable __kindof UIView *)firstSuperviewWithClass:(nonnull Class)viewClass;

/*! Returns the UIViewController owning the receiver's view tree if it exists
 */
- (nullable __kindof UIViewController *)findViewController;

@end
