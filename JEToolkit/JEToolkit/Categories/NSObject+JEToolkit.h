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
#import <UIKit/UIKit.h>

@interface NSObject (JEToolkit)

#pragma mark - Class Utilities

/*! Convenience method for NSStringFromClass(self)
 */
+ (nonnull NSString *)fullyQualifiedClassName;

/*! Returns the fully-qualified class name relative to the specified namespace. For example, for class name "MyApp.MyClass", this method returns "MyClass" for namespace "MyApp". For classes outside "MyApp", this method returns "SomeExternalModule.SomeClass".
 */
+ (nonnull NSString *)classNameInNameSpace:(nonnull NSString *)namespace;

/*! Returns the fully-qualified class name relative to the main bundle. For example, for class name "MyApp.MyClass", this method returns "MyClass". For classes outside "MyApp", this method returns "SomeExternalModule.SomeClass".
 */
+ (nonnull NSString *)classNameInAppModule;

/*! Returns the iPhone or iPad-specific subclass for the receiver if they exist. Device-specific subclass names are expected to have either the suffix "_iPad" or "_iPhone".
 */
+ (nonnull Class)classForIdiom;

/*! Allocates an instance of the iPhone or iPad-specific subclass for the receiver
 */
+ (nonnull instancetype)allocForIdiom;


#pragma mark - Observing

/*! Registers the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to observe
 @param block The notification block
 */
- (void)registerForNotificationsWithName:(nonnull NSString *)notificationName
                             targetBlock:(nonnull void (^)(NSNotification *_Nonnull note))block;

/*! Registers the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to observe
 @param objectOrNil The NSNotification object to observe
 @param block The notification block
 */
- (void)registerForNotificationsWithName:(nonnull NSString *)notificationName
                              fromObject:(nullable id)objectOrNil
                             targetBlock:(nonnull void (^)(NSNotification *_Nonnull note))block;

/*! Registers the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to observe
 @param objectOrNil The NSNotification object to observe
 @param queueOrNil The queue to execute the notification block on
 @param block The notification block
 */
- (void)registerForNotificationsWithName:(nonnull NSString *)notificationName
                              fromObject:(nullable id)objectOrNil
                             targetQueue:(nullable NSOperationQueue *)queueOrNil
                             targetBlock:(nonnull void (^)(NSNotification *_Nonnull note))block;

/*! Unregisters the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to stop observing
 */
- (void)unregisterForNotificationsWithName:(nonnull NSString *)notificationName;

/*! Unregisters the receiver for NSNotificationCenter callbacks.
 @param notificationName The NSNotification name to cancel observing
 @param objectOrNil The NSNotification object to cancel observing
 */
- (void)unregisterForNotificationsWithName:(nonnull NSString *)notificationName
                                fromObject:(nullable id)objectOrNil;


#pragma mark - Method Swizzling

/*! Swizzles a class method.
 @param originalSelector The original method implementation
 @param overrideSelector The overriding method implementation
 */
+ (void)swizzleClassMethod:(nonnull SEL)originalSelector
        withOverrideMethod:(nonnull SEL)overrideSelector;

/*! Swizzles an instance method.
 @param originalSelector The original method implementation
 @param overrideSelector The overriding method implementation
 */
+ (void)swizzleInstanceMethod:(nonnull SEL)originalSelector
           withOverrideMethod:(nonnull SEL)overrideSelector;


#pragma mark - Object Tagging

/*! Provides object-tagging.
 */
@property (nonatomic, strong, nullable) NSUUID *dispatchTaskID;


#pragma mark - Internal

+ (nonnull instancetype)je_appearanceWhenContainedIn:(nonnull NSArray<Class <UIAppearanceContainer>> *)containerTypes;

@end
