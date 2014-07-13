//
//  NSDateFormatter+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/12.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSDateFormatter+JEToolkit.h"

#import "NSCalendar+JEToolkit.h"
#import "NSString+JEToolkit.h"


@implementation NSDateFormatter (JEToolkit)

#pragma mark - Public

+ (NSDateFormatter *)ISO8601UTCDateFormatter {
    
    static NSDateFormatter *ISO8601UTCDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDateFormatter *formatter = [[self alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [formatter setCalendar:[NSCalendar gregorianCalendar]];
        
        // http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        ISO8601UTCDateFormatter = formatter;
        
    });
    
    return ISO8601UTCDateFormatter;
}

+ (NSDateFormatter *)EXIFDateFormatter {
    
    static NSDateFormatter *EXIFDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDateFormatter *formatter = [[self alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [formatter setCalendar:[NSCalendar gregorianCalendar]];
        
        // http://unicode.org/reports/tr35/tr35-10.html#Date_Format_Patterns
        [formatter setDateFormat:@"yyyy':'MM':'dd' 'HH':'mm':'ss"];
        EXIFDateFormatter = formatter;
        
    });
    
    return EXIFDateFormatter;
}


@end
