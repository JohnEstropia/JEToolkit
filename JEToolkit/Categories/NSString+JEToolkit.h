//
//  NSString+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/06/16.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"


@interface NSString (JEToolkit)

#pragma mark - Paths

/*! Convenience method to get the app Documents path
 */
+ (NSString *)documentsDirectory JE_CONST;

/*! Convenience method to get the app Temporary path
 */
+ (NSString *)temporaryDirectory JE_CONST;

/*! Convenience method to get the app Caches path
 */
+ (NSString *)cachesDirectory JE_CONST;

/*! Convenience method to get the app Application Support path
 */
+ (NSString *)appSupportDirectory JE_CONST;


#pragma mark - String Manipulation

/*! Removes leading and trailing whitespace characters from the receiver
 */
- (NSString *)trimmedString;

/*! Gets the array of characters from the receiver
 */
- (NSArray *)charactersArray;


#pragma mark - Validation

/*! Checks if value is nil, if it's an NSString instance, if its length is 0, or if all its characters are whitespace.
 */
+ (BOOL)isNilOrEmptyString:(id)valueOrNil;

/*! Checks if value is an NSString instance and returns the trimmed string if it's not empty. Returns nil otherwise.
 */
+ (NSString *)nonEmptyStringOrNil:(id)valueOrNil;

- (BOOL)containsSubstring:(NSString *)substring JE_NONNULL_ALL;

- (BOOL)containsSubstring:(NSString *)substring
                  options:(NSStringCompareOptions)options JE_NONNULL(1);


#pragma mark - Conversion

/*! Extracts a string from the given value.
 @param valueOrNil The object to extract string from. Accepts nil, NSString, NSNumber, or UTF-8 NSData
 @return valueOrNil if it is an NSString, the numerical string if valueOrNil is an NSNumber, the UTF-8 string value of an NSData, or nil otherwise.
 */
+ (NSString *)stringFromValue:(id)valueOrNil;

/*! Returns the shorthand display string for a file size
 @param fileSize The number of bytes to represent as a string
 */
+ (NSString *)stringFromFileSize:(int64_t)fileSize;

/*! Returns a canonical string suitable for optimizing string queries and other string-based indexing
 */
- (NSString *)canonicalString;


@end
