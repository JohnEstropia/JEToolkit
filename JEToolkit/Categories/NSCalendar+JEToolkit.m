//
//  NSCalendar+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSCalendar+JEToolkit.h"

@implementation NSCalendar (JEToolkit)

+ (NSCalendar *)cachedLocalizedCalendar
{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        calendar = [self currentCalendar];
        
    });
    return calendar;
}

+ (NSCalendar *)gregorianCalendar
{
    static NSCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        calendar = [[self alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
    });
    return calendar;
}

@end
