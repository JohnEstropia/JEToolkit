//
//  NSCalendar+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JREToolkitDefines.h"


/*! NSCalendar category for caching calendars, as creating NSCalendar objects is not very performant.
 */
@interface NSCalendar (JREToolkit)

/*! Create and caches the NSCalendar returned from [NSCalendar currentCalendar].
 */
+ (NSCalendar *)cachedCalendar JRE_CONST;

/*! Create and caches the NSCalendar created with NSGregorianCalendar identifier.
 */
+ (NSCalendar *)gregorianCalendar JRE_CONST;

@end
