//
//  NSNumber+JEDebugging.m
//  JEToolkit
//
//  Created by DIT John Estropia on 2013/11/28.
//  Copyright (c) 2013年 John Rommel Estropia. All rights reserved.
//

#import "NSNumber+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSNumber (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSMutableString *description;
    if (self == (id)kCFBooleanTrue)
    {
        description = [[NSMutableString alloc] initWithString:@"@YES"];
    }
    else if (self == (id)kCFBooleanFalse)
    {
        description = [[NSMutableString alloc] initWithString:@"@NO"];
    }
    else
    {
        description = [super detailedDescriptionIncludeClass:NO includeAddress:NO];
        [description insertString:@"@(" atIndex:0];
        [description appendString:@")"];
    }
    
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
