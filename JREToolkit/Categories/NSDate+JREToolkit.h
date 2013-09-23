//
//  NSDate+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (JREToolkit)

#pragma mark - Conversion

+ (NSDate *)dateWithObject:(id)objectOrNil;

/*! Returns an NSDate from an ISO 8601 UTC formatted date (ex: 2013-03-20T15:30:20Z), or nil if conversion fails. Note: only supports UTC
 */
+ (NSDate *)dateWithISO8601String:(NSString *)ISO8601String;

/*! Returns the ISO 8601 UTC date format (ex: 2013-03-20T15:30:20Z) for the receiver
 */
- (NSString *)ISO8601String;


@end
