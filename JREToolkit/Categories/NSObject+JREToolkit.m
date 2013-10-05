//
//  NSObject+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSObject+JREToolkit.h"

@implementation NSObject (JREToolkit)

#pragma mark - public

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

@end
