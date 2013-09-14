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


#pragma mark - Paths

/*! Convenience method to get the app Documents path
 */
+ (NSString *)pathToDocumentsDirectory;

/*! Convenience method to get the app Temporary path
 */
+ (NSString *)pathToTemporaryDirectory;

/*! Convenience method to get the app Caches path
 */
+ (NSString *)pathToCachesDirectory;

/*! Convenience method to get the app Application Support path
 */
+ (NSString *)pathToAppSupportDirectory;


#pragma mark - String Manipulation

/*! Removes leading and trailing whitespace characters from the receiver
 */
- (NSString *)trimmedString;


#pragma mark - Validation

/*! Extracts a string from the given value.
 @param value The object to extract string from
 
 @return value if it is an NSString, the numerical string if value is an NSNumber, the UTF-8 string value of an NSData, or nil otherwise.
 */
+ (NSString *)stringFromValue:(id)value;

/*! Checks if the receiver's length is 0, or if all its characters are whitespace.
 */
- (BOOL)isEmpty;


@end
