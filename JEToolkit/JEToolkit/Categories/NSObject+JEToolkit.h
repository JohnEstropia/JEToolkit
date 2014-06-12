//
//  NSObject+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JEToolkit)

#pragma mark - Class Utilities

/*! Convenience method for NSStringFromClass(self)
 */
+ (NSString *)className;

/*! Returns the iPhone or iPad-specific subclass for the receiver if they exist. Device-specific subclass names are expected to have either the suffix "_iPad" or "_iPhone".
 */
+ (Class)classForIdiom;

/*! Allocates an instance of the iPhone or iPad-specific subclass for the receiver
 */
+ (instancetype)allocForIdiom;


#pragma mark - Method Swizzling

/*! Swizzles a class method.
 @param originalSelector The original method implementation
 @param overrideSelector The overriding method implementation
 */
+ (void)swizzleClassMethod:(SEL)originalSelector
        withOverrideMethod:(SEL)overrideSelector;

/*! Swizzles an instance method.
 @param originalSelector The original method implementation
 @param overrideSelector The overriding method implementation
 */
+ (void)swizzleInstanceMethod:(SEL)originalSelector
           withOverrideMethod:(SEL)overrideSelector;


@end
