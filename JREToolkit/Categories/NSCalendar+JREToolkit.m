//
//  NSCalendar+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSCalendar+JREToolkit.h"

@implementation NSCalendar (JREToolkit)

+ (NSCalendar *)cachedCalendar
{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        calendar = [NSCalendar currentCalendar];
        
    });
    return calendar;
}

+ (NSCalendar *)gregorianCalendar
{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
    });
    return calendar;
}

@end
