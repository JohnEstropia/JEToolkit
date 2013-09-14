//
//  NSDateFormatter+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/12.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatter (JREToolkit)

+ (NSDateFormatter *)ISO8601UTCDateFormatter; // 2013-03-20T12:30:20Z
+ (NSDateFormatter *)EXIFDateFormatter; // 2013:03:20 12:30:20

- (NSDate *)dateFromValue:(id)value;

@end
