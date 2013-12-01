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
    NSMutableString *description = [[NSMutableString alloc] initWithString:[self description]];
    [description indentByLevel:1];
    if (includeAddress)
    {
        [description insertString:[NSString stringWithFormat:@"<%p> ", self] atIndex:0];
    }
    if (includeClass)
    {
        [description insertString:[NSString stringWithFormat:@"(%@ *) ", [self class]] atIndex:0];
    }
    return description;
}

@end
