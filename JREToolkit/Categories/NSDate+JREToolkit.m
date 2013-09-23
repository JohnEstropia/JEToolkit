//
//  NSDate+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSDate+JREToolkit.h"

#import "NSCalendar+JREToolkit.h"
#import "NSDateFormatter+JREToolkit.h"


@implementation NSDate (JREToolkit)

#pragma mark - public

#pragma mark Conversion

+ (NSDate *)dateWithObject:(id)objectOrNil
{
    if (!objectOrNil)
    {
        return nil;
    }
    if ([objectOrNil isKindOfClass:self])
    {
        return objectOrNil;
    }
    if ([objectOrNil isKindOfClass:[NSNumber class]])
    {
        return [self dateWithTimeIntervalSince1970:[(NSNumber *)objectOrNil doubleValue]];
    }
    if ([objectOrNil isKindOfClass:[NSString class]])
    {
        return [self dateWithISO8601String:objectOrNil];
    }
    return nil;
}

+ (NSDate *)dateWithISO8601String:(NSString *)ISO8601String
{
    NSCParameterAssert([ISO8601String isKindOfClass:[NSString class]]);
    
    return [[NSDateFormatter ISO8601UTCDateFormatter] dateFromString:ISO8601String];
}

- (NSString *)ISO8601String
{
    return [[NSDateFormatter ISO8601UTCDateFormatter] stringFromDate:self];
}


@end
