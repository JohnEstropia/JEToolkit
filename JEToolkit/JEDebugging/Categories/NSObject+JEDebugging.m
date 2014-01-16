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

- (NSMutableString *)detailedDescription
{
    return [self detailedDescriptionIncludeClass:YES includeAddress:YES];
}

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSMutableString *description = [self
                                    stringBuilderForDetailedDescriptionIncludeClass:includeClass
                                    includeAddress:includeAddress];
    [description appendString:[self description]];
    [description indentByLevel:1];
    return description;
}

- (NSMutableString *)stringBuilderForDetailedDescriptionIncludeClass:(BOOL)includeClass
                                                      includeAddress:(BOOL)includeAddress
{
    NSMutableString *description = [[NSMutableString alloc] init];
    if (includeClass)
    {
        [description appendFormat:@"(%@ *) ", [self class]];
    }
    if (includeAddress)
    {
        [description appendFormat:@"<%p> ", self];
    }
    return description;
}

@end
