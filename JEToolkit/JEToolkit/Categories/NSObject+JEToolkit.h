//
//  NSObject+JEToolkit.h
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

#import <Foundation/Foundation.h>

@interface NSObject (JEToolkit)

#pragma mark - Class Utilities

/*! Convenience method for NSStringFromClass(self)
 */
+ (NSString *)className;

/*! Returns the fully-qualified class name relative to the main bundle. For example, for class name "MyApp.MyClass", this method returns "MyClass". For classes outside "MyApp", this method returns "SomeExternalModule.SomeClass".
 */
+ (NSString *)classNameInAppModule;

/*! Returns the fully-qualified class name relative to the specified module. For example, for class name "MyApp.MyClass", this method returns "MyClass" for moduleName "MyApp". For classes outside "MyApp", this method returns "SomeExternalModule.SomeClass".
 */
+ (NSString *)classNameInModule:(NSString *)moduleName;

/*! Returns the iPhone or iPad-specific subclass for the receiver if they exist. Device-specific subclass names are expected to have either the suffix "_iPad" or "_iPhone".
 */
+ (Class)classForIdiom;

/*! Allocates an instance of the iPhone or iPad-specific subclass for the receiver
 */
+ (instancetype)allocForIdiom;


#pragma mark - Observing

/*! Registers the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to observe
 @param block The notification block
 */
- (void)registerForNotificationsWithName:(NSString *)notificationName
                             targetBlock:(void (^)(NSNotification *note))block;

/*! Registers the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to observe
 @param objectOrNil The NSNotification object to observe
 @param block The notification block
 */
- (void)registerForNotificationsWithName:(NSString *)notificationName
                              fromObject:(id)objectOrNil
                             targetBlock:(void (^)(NSNotification *note))block;

/*! Registers the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to observe
 @param objectOrNil The NSNotification object to observe
 @param queueOrNil The queue to execute the notification block on
 @param block The notification block
 */
- (void)registerForNotificationsWithName:(NSString *)notificationName
                              fromObject:(id)objectOrNil
                             targetQueue:(NSOperationQueue *)queueOrNil
                             targetBlock:(void (^)(NSNotification *note))block;

/*! Unregisters the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to stop observing
 */
- (void)unregisterForNotificationsWithName:(NSString *)notificationName;

/*! Unregisters the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to cancel observing
 @param objectOrNil The NSNotification object to cancel observing
 */
- (void)unregisterForNotificationsWithName:(NSString *)notificationName
                                fromObject:(id)objectOrNil;


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
