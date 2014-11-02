//
//  NSObject+JEToolkit.m
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

#import "NSObject+JEToolkit.h"

#import <objc/runtime.h>

#import "JESynthesize.h"
#import "JEDebugging.h"


@interface _JE_NSNotificationObserver : NSObject

@property (nonatomic, copy, readonly) NSString *notificationName;
@property (nonatomic, weak, readonly) id object;
@property (nonatomic, weak, readonly) id<NSObject> observer;

@end

@implementation _JE_NSNotificationObserver

- (instancetype)initWithName:(NSString *)notificationName
                      object:(id)objectOrNil
                       queue:(NSOperationQueue *)queue
                  usingBlock:(void (^)(NSNotification *note))block {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    _notificationName = notificationName;
    _object = objectOrNil;
    _observer = [[NSNotificationCenter defaultCenter]
                 addObserverForName:notificationName
                 object:objectOrNil
                 queue:queue
                 usingBlock:block];
    return self;
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:_observer
     name:_notificationName
     object:_object];
}

- (void)stopObserving {
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self.observer
     name:self.notificationName
     object:self.object];
}

@end


@implementation NSObject (JEToolkit)

#pragma mark - Private

JESynthesize(strong, NSMutableDictionary *, _je_notificationObservers, _je_setNotificationObservers)

+ (NSString *)je_keyForObserverWithNotificationName:(NSString *)notificationName
                                             object:(id)objectOrNil {
    
    return [[NSString alloc] initWithFormat:@"%p:%@", objectOrNil, notificationName];
}

- (NSMutableDictionary *)je_notificationObservers {
    
    NSMutableDictionary *observers = [self _je_notificationObservers];
    if (!observers) {
        
        observers = [[NSMutableDictionary alloc] init];
        [self _je_setNotificationObservers:observers];
    }
    return observers;
}


#pragma mark - Public

#pragma mark Class Utilities

+ (NSString *)className {
    
    return NSStringFromClass(self);
}

+ (Class)classForIdiom {
    
    static NSString *idiom;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        idiom = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
                 ? @"iPad"
                 : @"iPhone");
        
    });
    
    NSString *className = [self className];
    return (NSClassFromString([[NSString alloc] initWithFormat:@"%@_%@", className, idiom])
            ?: NSClassFromString(className));
}

+ (instancetype)allocForIdiom {
    
    return [[self classForIdiom] alloc];
}


#pragma mark Observing

- (void)registerForNotificationsWithName:(NSString *)notificationName
                             targetBlock:(void (^)(NSNotification *note))block {
    
    [self
     registerForNotificationsWithName:notificationName
     fromObject:nil
     targetQueue:nil
     targetBlock:block];
}

- (void)registerForNotificationsWithName:(NSString *)notificationName
                              fromObject:(id)objectOrNil
                             targetBlock:(void (^)(NSNotification *note))block {
    
    [self
     registerForNotificationsWithName:notificationName
     fromObject:objectOrNil
     targetQueue:nil
     targetBlock:block];
}

- (void)registerForNotificationsWithName:(NSString *)notificationName
                              fromObject:(id)objectOrNil
                             targetQueue:(NSOperationQueue *)queueOrNil
                             targetBlock:(void (^)(NSNotification *note))block {
    
    NSMutableDictionary *je_notificationObservers = [self je_notificationObservers];
    NSString *key = [NSObject je_keyForObserverWithNotificationName:notificationName object:objectOrNil];
    
    [(_JE_NSNotificationObserver *)je_notificationObservers[key] stopObserving];
    je_notificationObservers[key] = [[_JE_NSNotificationObserver alloc]
                                     initWithName:notificationName
                                     object:objectOrNil
                                     queue:queueOrNil
                                     usingBlock:block];
}

- (void)unregisterForNotificationsWithName:(NSString *)notificationName {
    
    [self unregisterForNotificationsWithName:notificationName fromObject:nil];
}

- (void)unregisterForNotificationsWithName:(NSString *)notificationName
                                fromObject:(id)objectOrNil {
    
    [[self _je_notificationObservers] removeObjectForKey:
     [NSObject je_keyForObserverWithNotificationName:notificationName object:objectOrNil]];
}


#pragma mark Method Swizzling

+ (void)swizzleClassMethod:(SEL)originalSelector
        withOverrideMethod:(SEL)overrideSelector {
    
    Class metaClass = object_getClass(self);
    
	Method originalMethod = class_getInstanceMethod(metaClass, originalSelector);
    JEAssert(originalMethod != NULL,
             @"Original method +[%@ %@] does not exist.",
             NSStringFromClass(self),
             NSStringFromSelector(originalSelector));
    
	Method overrideMethod = class_getInstanceMethod(metaClass, overrideSelector);
    JEAssert(overrideMethod != NULL,
             @"Override method +[%@ %@] does not exist.",
             NSStringFromClass(self),
             NSStringFromSelector(overrideSelector));
    
    if (originalMethod == overrideMethod) {
        
        return;
    }
    
    class_addMethod(metaClass,
					originalSelector,
					class_getMethodImplementation(self, originalSelector),
					method_getTypeEncoding(originalMethod));
	class_addMethod(metaClass,
					overrideSelector,
					class_getMethodImplementation(self, overrideSelector),
					method_getTypeEncoding(overrideMethod));
    
	method_exchangeImplementations(class_getInstanceMethod(metaClass, originalSelector),
                                   class_getInstanceMethod(metaClass, overrideSelector));
}

+ (void)swizzleInstanceMethod:(SEL)originalSelector
           withOverrideMethod:(SEL)overrideSelector {
    
	Method originalMethod = class_getInstanceMethod(self, originalSelector);
    JEAssert(originalMethod != NULL,
             @"Original method -[%@ %@] does not exist.",
             NSStringFromClass(self),
             NSStringFromSelector(originalSelector));
    
	Method overrideMethod = class_getInstanceMethod(self, overrideSelector);
    JEAssert(overrideMethod != NULL,
             @"Override method -[%@ %@] does not exist.",
             NSStringFromClass(self),
             NSStringFromSelector(overrideSelector));
    
    if (originalMethod == overrideMethod) {
        
        return;
    }
    
    class_addMethod(self,
					originalSelector,
					class_getMethodImplementation(self, originalSelector),
					method_getTypeEncoding(originalMethod));
	class_addMethod(self,
					overrideSelector,
					class_getMethodImplementation(self, overrideSelector),
					method_getTypeEncoding(overrideMethod));
    
	method_exchangeImplementations(class_getInstanceMethod(self, originalSelector),
                                   class_getInstanceMethod(self, overrideSelector));
}

@end
