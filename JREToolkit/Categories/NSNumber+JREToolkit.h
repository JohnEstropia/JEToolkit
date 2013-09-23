//
//  NSNumber+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (JREToolkit)

#pragma mark - Conversion

/*! Extracts an NSNumber from a given value.
 */
+ (NSNumber *)numberFromValue:(id)valueOrNil;


#pragma mark - Displaying to user

/*! Returns a localized string representation of the number
 */
- (NSString *)displayString;

@end
