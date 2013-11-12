//
//  NSNumber+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (JEToolkit)

#pragma mark - Conversion

/*! Extracts a number from the given value.
 @param valueOrNil The object to extract number from. Accepts nil, NSNumber, a decimal-formatted NSString, or an NSDate
 @return valueOrNil if it is an NSNumber, the numerical value of an NSString, the Unix timestamp from an NSDate, or nil otherwise.
 */
+ (NSNumber *)numberFromValue:(id)valueOrNil;


#pragma mark - Displaying to user

/*! Returns a localized string representation of the number
 */
- (NSString *)displayString;

@end
