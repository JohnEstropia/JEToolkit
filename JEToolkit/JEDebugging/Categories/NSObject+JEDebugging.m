//
//  NSObject+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSObject+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSObject (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [self loggingDescriptionIncludeClass:YES includeAddress:YES];
}


#pragma mark - Public

- (NSString *)loggingDescription
{
    return [self description];
}

- (NSString *)loggingDescriptionIncludeClass:(BOOL)includeClass
                              includeAddress:(BOOL)includeAddress
{
    NSMutableString *description = [NSMutableString string];
    if (includeClass)
    {
        [description appendFormat:@"(%@ *) ", [self class]];
    }
    if (includeAddress)
    {
        [description appendFormat:@"<%p> ", self];
    }
    [description appendString:[self loggingDescription]];
    [description indentByLevel:1];
    return description;
}


@end
