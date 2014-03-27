//
//  NSObject+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSObject+JEToolkit.h"

#import "NSMutableString+JEToolkit.h"


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


@end
