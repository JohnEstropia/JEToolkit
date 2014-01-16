//
//  NSNumber+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSNumber+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSNumber (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSMutableString *description = [self
                                    stringBuilderForDetailedDescriptionIncludeClass:includeClass
                                    includeAddress:includeAddress];
    if (self == (id)kCFBooleanTrue)
    {
        [description appendString:@"@YES"];
    }
    else if (self == (id)kCFBooleanFalse)
    {
        [description appendString:@"@NO"];
    }
    else
    {
        [description appendString:@"@("];
        [description appendString:[super detailedDescriptionIncludeClass:NO includeAddress:NO]];
        [description appendString:@")"];
    }
    
    return description;
}

@end
