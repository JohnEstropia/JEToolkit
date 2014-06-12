//
//  NSString+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/06/16.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSString+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSString (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription
{
    NSMutableString *description = [NSMutableString stringWithString:self];
    [description escapeWithUTF8CStringRepresentation];
    [description insertString:@"@" atIndex:0];
    
    return description;
}


@end
