//
//  NSDate+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSDate+JEToolkit.h"

#import "NSCalendar+JEToolkit.h"
#import "NSDateFormatter+JEToolkit.h"

#import "JEDebugging.h"


@implementation NSDate (JEToolkit)

#pragma mark - Public

#pragma mark Conversion

+ (NSDate *)dateWithValue:(id)valueOrNil {
    
    if (!valueOrNil) {
        
        return nil;
    }
    if ([valueOrNil isKindOfClass:[NSDate class]]) {
        
        return valueOrNil;
    }
    if ([valueOrNil isKindOfClass:[NSNumber class]]) {
        
        return [self dateWithTimeIntervalSince1970:[(NSNumber *)valueOrNil doubleValue]];
    }
    if ([valueOrNil isKindOfClass:[NSString class]]) {
        
        return [self dateWithISO8601String:valueOrNil];
    }
    return nil;
}

+ (NSDate *)dateWithISO8601String:(NSString *)ISO8601String {
    
    JEAssertParameter([ISO8601String isKindOfClass:[NSString class]]);
    
    return [[NSDateFormatter ISO8601UTCDateFormatter] dateFromString:ISO8601String];
}

+ (NSDate *)dateWithEXIFString:(NSString *)EXIFString {
    
    JEAssertParameter([EXIFString isKindOfClass:[NSString class]]);
    
    return [[NSDateFormatter EXIFDateFormatter] dateFromString:EXIFString];
}

- (NSString *)ISO8601String {
    
    return [[NSDateFormatter ISO8601UTCDateFormatter] stringFromDate:self];
}

- (NSString *)EXIFString {
    
    return [[NSDateFormatter EXIFDateFormatter] stringFromDate:self];
}


@end
