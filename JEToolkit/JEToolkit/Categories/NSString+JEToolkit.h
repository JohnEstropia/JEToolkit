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


@interface NSString (JEToolkit)

#pragma mark - Directories

/*! Convenience method to get the app Application Support path
 */
+ (null_unspecified NSString *)applicationSupportDirectory;

/*! Convenience method to get the app Caches path
 */
+ (null_unspecified NSString *)cachesDirectory;

/*! Convenience method to get the app Documents path
 */
+ (null_unspecified NSString *)documentsDirectory;

/*! Convenience method to get the app Downloads path
 */
+ (null_unspecified NSString *)downloadsDirectory;

/*! Convenience method to get the app Library path
 */
+ (null_unspecified NSString *)libraryDirectory;

/*! Convenience method to get the app Temporary path
 */
+ (null_unspecified NSString *)temporaryDirectory;

/*! Convenience method to build file path from components
 */
+ (nonnull NSString *)pathWithComponents:(nonnull NSArray *)components pathExtension:(nullable NSString *)pathExtension;


#pragma mark - Constants

/*! Convenience method to get the app name string
 */
+ (null_unspecified NSString *)applicationName;

/*! Convenience method to get the app short version string
 */
+ (null_unspecified NSString *)applicationVersion;

/*! Convenience method to get the app bundle version string
 */
+ (null_unspecified NSString *)applicationBundleVersion;


#pragma mark - String Manipulation

/*! Removes leading and trailing whitespace characters from the receiver
 */
- (nonnull NSString *)trimmedString;

/*! Gets the array of characters from the receiver
 */
- (nonnull NSArray *)glyphs;

/*! Gets the range of the receiver
 */
- (NSRange)range;


#pragma mark - Validation

/*! Checks if value is nil, if it's an NSString instance, if its length is 0, or if all its characters are whitespace.
 */
+ (BOOL)isNilOrEmptyString:(nullable id)valueOrNil;

/*! Checks if value is an NSString instance and returns the trimmed string if it's not empty. Returns nil otherwise.
 */
+ (nullable NSString *)nonEmptyStringOrNil:(nullable id)valueOrNil;

/*! Checks if a string is a substring of the receiver.
 */
- (BOOL)containsSubstring:(nullable NSString *)substring;

/*! Checks if a string is a substring of the receiver.
 */
- (BOOL)containsSubstring:(nullable NSString *)substring
                  options:(NSStringCompareOptions)options;

/*! Returns an NSComparisonResult value that indicates the version ordering of the receiver and another version string.
 @param versionString The version string with which to compare the receiver.
 @return NSOrderedAscending if the value of versionString is greater than the receiver; NSOrderedSame if they’re equal; and NSOrderedDescending if the value of versionString is less than the receiver or if versionString is nil.
 */
- (NSComparisonResult)compareWithVersion:(nullable NSString *)versionString;


#pragma mark - Conversion

/*! Extracts a string from the given value.
 @param valueOrNil The object to extract string from. Accepts nil, NSString, NSNumber, or UTF-8 NSData
 @return valueOrNil if it is an NSString, the numerical string if valueOrNil is an NSNumber, the UTF-8 string value of an NSData, or nil otherwise.
 */
+ (nullable NSString *)stringFromValue:(nullable id)valueOrNil;

/*! Returns the shorthand display string for a file size
 @param fileSize The number of bytes to represent as a string
 */
+ (nonnull NSString *)stringFromFileSize:(int64_t)fileSize;

/*! Returns a canonical string suitable for optimizing string queries and other string-based indexing
 */
- (nonnull NSString *)canonicalString;

/*! Returns a URL-encoded string from the receiver
 */
- (nonnull NSString *)URLEncodedString;

/*! Returns a URL-decoded string from the receiver
 */
- (nullable NSString *)URLDecodedString;


@end
