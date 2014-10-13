//
//  NSString+JEToolkit.h
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"


@interface NSString (JEToolkit)

#pragma mark - Directories

/*! Convenience method to get the app Application Support path
 */
+ (NSString *)applicationSupportDirectory;

/*! Convenience method to get the app Caches path
 */
+ (NSString *)cachesDirectory;

/*! Convenience method to get the app Documents path
 */
+ (NSString *)documentsDirectory;

/*! Convenience method to get the app Downloads path
 */
+ (NSString *)downloadsDirectory;

/*! Convenience method to get the app Library path
 */
+ (NSString *)libraryDirectory;

/*! Convenience method to get the app Temporary path
 */
+ (NSString *)temporaryDirectory;

/*! Convenience method to build file path from components
 */
+ (NSString *)pathWithComponents:(NSArray *)components pathExtension:(NSString *)pathExtension;


#pragma mark - Constants

/*! Convenience method to get the app name string
 */
+ (NSString *)applicationName;

/*! Convenience method to get the app short version string
 */
+ (NSString *)applicationVersion;

/*! Convenience method to get the app bundle version string
 */
+ (NSString *)applicationBundleVersion;


#pragma mark - String Manipulation

/*! Removes leading and trailing whitespace characters from the receiver
 */
- (NSString *)trimmedString;

/*! Gets the array of characters from the receiver
 */
- (NSArray *)glyphs;

/*! Gets the range of the receiver
 */
- (NSRange)range;


#pragma mark - Validation

/*! Checks if value is nil, if it's an NSString instance, if its length is 0, or if all its characters are whitespace.
 */
+ (BOOL)isNilOrEmptyString:(id)valueOrNil;

/*! Checks if value is an NSString instance and returns the trimmed string if it's not empty. Returns nil otherwise.
 */
+ (NSString *)nonEmptyStringOrNil:(id)valueOrNil;

/*! Checks if a string is a substring of the receiver.
 */
- (BOOL)containsSubstring:(NSString *)substring JE_NONNULL_ALL;

/*! Checks if a string is a substring of the receiver.
 */
- (BOOL)containsSubstring:(NSString *)substring
                  options:(NSStringCompareOptions)options JE_NONNULL(1);

/*! Returns an NSComparisonResult value that indicates the version ordering of the receiver and another version string.
 @param versionString The version string with which to compare the receiver.
 @return NSOrderedAscending if the value of versionString is greater than the receiver; NSOrderedSame if they’re equal; and NSOrderedDescending if the value of versionString is less than the receiver or if versionString is nil.
 */
- (NSComparisonResult)compareWithVersion:(NSString *)versionString;


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
