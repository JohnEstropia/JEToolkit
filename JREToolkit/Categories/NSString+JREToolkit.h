//
//  NSString+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/06/16.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JREToolkit)

#pragma mark - Localization

/*! Convenience method for NSLocalizedString().
 @return The value for the entry in Localizable.strings specified by the receiver
 */
- (NSString *)L8N;

/*! Convenience method for NSLocalizedStringFromTable().
 @param stringsFile The filename of the .strings file without the file extension.
 @return The value for the entry in Localizable.strings specified by the receiver
 */
- (NSString *)L8NInStringsFile:(NSString *)stringsFile;


#pragma mark - Paths

/*! Convenience method to get the app Documents path
 */
+ (NSString *)documentsDirectory;

/*! Convenience method to get the app Temporary path
 */
+ (NSString *)temporaryDirectory;

/*! Convenience method to get the app Caches path
 */
+ (NSString *)cachesDirectory;

/*! Convenience method to get the app Application Support path
 */
+ (NSString *)appSupportDirectory;


#pragma mark - String Manipulation

/*! Removes leading and trailing whitespace characters from the receiver
 */
- (NSString *)trimmedString;


#pragma mark - Validation

/*! Checks if value is nil, if it's an NSString instance, if its length is 0, or if all its characters are whitespace.
 */
+ (BOOL)isNilOrEmptyString:(id)valueOrNil;

/*! Checks if value is an NSString instance and returns the trimmed string if it's not empty. Returns nil otherwise.
 */
+ (NSString *)nonEmptyStringOrNil:(id)valueOrNil;


#pragma mark - Conversion

/*! Extracts a string from the given value.
 @param value The object to extract string from
 @return value if it is an NSString, the numerical string if value is an NSNumber, the UTF-8 string value of an NSData, or nil otherwise.
 */
+ (NSString *)stringFromValue:(id)valueOrNil;



@end
