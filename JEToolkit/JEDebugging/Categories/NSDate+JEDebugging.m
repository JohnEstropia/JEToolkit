//
//  NSDate+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSDate+JEDebugging.h"

#import "NSDate+JEToolkit.h"


@implementation NSDate (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription
{
    return [NSString stringWithFormat:
            @"%@ (%@)",
            [self ISO8601String], [NSDateFormatter
                                   localizedStringFromDate:self
                                   dateStyle:NSDateFormatterMediumStyle
                                   timeStyle:NSDateFormatterLongStyle]];
}


@end
