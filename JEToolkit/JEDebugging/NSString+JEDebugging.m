//
//  NSString+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSString+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSString (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:[self debugDescription]];
    [description replaceWithCStringRepresentation];
    [description insertString:@"@" atIndex:0];
    
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
