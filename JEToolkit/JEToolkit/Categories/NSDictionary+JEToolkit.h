//
//  NSDictionary+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/12/04.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JEToolkit)

/*! Extracts a dictionary from the given value.
 @param valueOrNil The object to extract a dictionary from. Accepts nil, NSDictionary, a JSON string, or a JSON NSData
 @return valueOrNil if it is an NSDictionary, a dictionary representation of a JSON NSData or string, or nil otherwise.
 */
+ (nullable NSDictionary *)dictionaryFromValue:(nullable id)valueOrNil;

@end
