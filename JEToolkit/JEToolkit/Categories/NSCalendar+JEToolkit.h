//
//  NSCalendar+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"


@interface NSCalendar (JEToolkit)

/*! Create and caches the NSCalendar returned from [NSCalendar currentCalendar].
 */
+ (NSCalendar *)cachedLocalizedCalendar JE_CONST;

/*! Create and caches the NSCalendar created with NSGregorianCalendar identifier.
 */
+ (NSCalendar *)gregorianCalendar JE_CONST;

@end
