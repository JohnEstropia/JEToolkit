//
//  NSNumber+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSNumber+JEDebugging.h"

#import "NSObject+JEDebugging.h"


@implementation NSNumber (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription
{
    if (self == (id)kCFBooleanTrue)
    {
        return @"@YES";
    }
    else if (self == (id)kCFBooleanFalse)
    {
        return @"@NO";
    }
    else
    {
        return [NSString stringWithFormat:
                @"@(%@)",
                [super loggingDescription]];
    }
}


@end
