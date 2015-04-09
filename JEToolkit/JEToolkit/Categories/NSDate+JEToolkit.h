//
//  NSDate+JEToolkit.h
//  JEToolkit
//
//  Copyright (c) 2014 John Rommel Estropia
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


@interface NSDate (JEToolkit)

#pragma mark - Conversion

/*! Extracts a date from the given value.
 @param valueOrNil The object to extract date from. Accepts nil, NSDate, a Unix timestamp NSNumber, or an ISO 8601 formatted UTC NSString
 @return valueOrNil if it is an NSDate, date representatin of a Unix timestamp NSNumber, the date from an ISO 8601 formatted UTC NSString, or nil otherwise.
 */
+ (nullable NSDate *)dateForValue:(nullable id)valueOrNil;

/*! Returns an NSDate from an ISO 8601 UTC formatted date (ex: 2013-03-20T15:30:20Z), or nil if conversion fails. Note: only supports UTC
 */
+ (nullable NSDate *)dateWithISO8601String:(nonnull NSString *)ISO8601String;

/*! Returns an NSDate from an EXIF formatted date (ex: 2013:03:20 15:30:20), or nil if conversion fails. Note: only supports UTC
 */
+ (nullable NSDate *)dateWithEXIFString:(nonnull NSString *)EXIFString;

/*! Returns the ISO 8601 UTC date format (ex: 2013-03-20T15:30:20Z) for the receiver
 */
- (nonnull NSString *)ISO8601String;

/*! Returns the EXIF date format (ex: 2013:03:20 15:30:20) for the receiver
 */
- (nonnull NSString *)EXIFString;


@end
