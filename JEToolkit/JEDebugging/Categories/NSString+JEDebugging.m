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
    NSMutableString *description = [self
                                    stringBuilderForDetailedDescriptionIncludeClass:includeClass
                                    includeAddress:includeAddress];
    [description appendString:@"@"];
    
    NSMutableString *UTF8CString = [[NSMutableString alloc] initWithString:[self description]];
    [UTF8CString escapeWithUTF8CStringRepresentation];
    [description appendString:UTF8CString];
    
    return description;
}

@end
