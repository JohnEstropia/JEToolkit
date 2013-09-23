//
//  NSDateFormatter+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/12.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! NSDateFormatter category for caching date formatters, as creating NSDateFormatter objects is not very performant.
 */
@interface NSDateFormatter (JREToolkit)

#pragma mark - Shared Formatters

/*! NSDateFormatter for dates in ISO 8601 UTC date format (ex: 2013-03-20T15:30:20Z). Note: only supports UTC
 */
+ (NSDateFormatter *)ISO8601UTCDateFormatter;

/*! NSDateFormatter for dates in EXIF date format (ex: 2013-03-20 15:30:20). Note: only supports UTC
 */
+ (NSDateFormatter *)EXIFDateFormatter;


@end
