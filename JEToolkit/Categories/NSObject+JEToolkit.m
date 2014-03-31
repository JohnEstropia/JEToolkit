//
//  NSObject+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSObject+JEToolkit.h"

#import <objc/runtime.h>

#import "NSMutableString+JEToolkit.h"
#import "JEDebugging.h"


@implementation NSObject (JEToolkit)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [self loggingDescriptionIncludeClass:YES includeAddress:YES];
}


#pragma mark - Public

#pragma mark Class Utilities

+ (NSString *)className
{
    return NSStringFromClass(self);
}

+ (Class)classForIdiom
{
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

+ (instancetype)allocForIdiom
{
    return [[self classForIdiom] alloc];
}


#pragma mark Logging

- (NSString *)loggingDescription
{
    return [self description];
}

- (NSString *)loggingDescriptionIncludeClass:(BOOL)includeClass
                              includeAddress:(BOOL)includeAddress
{
    NSMutableString *description = [NSMutableString string];
    @autoreleasepool {
        
        if (includeClass)
        {
            [description appendFormat:@"(%@ *) ", [self class]];
        }
        if (includeAddress)
        {
            [description appendFormat:@"<%p> ", self];
        }
        [description appendString:[self loggingDescription]];
        
    }
    return description;
}

#pragma mark Method Swizzling

+ (void)swizzleClassMethod:(SEL)originalSelector
        withOverrideMethod:(SEL)overrideSelector
{
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
           withOverrideMethod:(SEL)overrideSelector
{
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
