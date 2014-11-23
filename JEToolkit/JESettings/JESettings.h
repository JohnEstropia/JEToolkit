//
//  JESettingsBase.h
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
#import <UIKit/UIKit.h>


@interface JESettings : NSObject

- (long long int)integerValueForKey:(NSString *)key;
- (void)setIntegerValue:(long long int)value forKey:(NSString *)key;

- (unsigned long long int)unsignedIntegerValueForKey:(NSString *)key;
- (void)setUnsignedIntegerValue:(unsigned long long int)value forKey:(NSString *)key;

- (bool)booleanValueForKey:(NSString *)key;
- (void)setBooleanValue:(bool)value forKey:(NSString *)key;

- (float)floatValueForKey:(NSString *)key;
- (void)setFloatValue:(float)value forKey:(NSString *)key;

- (double)doubleValueForKey:(NSString *)key;
- (void)setDoubleValue:(double)value forKey:(NSString *)key;

- (NSString *)NSStringValueForKey:(NSString *)key;
- (void)setNSStringValue:(NSString *)value forKey:(NSString *)key;

- (NSNumber *)NSNumberValueForKey:(NSString *)key;
- (void)setNSNumberValue:(NSNumber *)value forKey:(NSString *)key;

- (NSDate *)NSDateValueForKey:(NSString *)key;
- (void)setNSDateValue:(NSDate *)value forKey:(NSString *)key;

- (NSData *)NSDataValueForKey:(NSString *)key;
- (void)setNSDataValue:(NSData *)value forKey:(NSString *)key;

- (NSURL *)NSURLValueForKey:(NSString *)key;
- (void)setNSURLValue:(NSURL *)value forKey:(NSString *)key;

- (NSUUID *)NSUUIDValueForKey:(NSString *)key;
- (void)setNSUUIDValue:(NSUUID *)value forKey:(NSString *)key;

- (id<NSCoding>)NSCodingValueForKey:(NSString *)key;
- (void)setNSCodingValue:(id<NSCoding>)value forKey:(NSString *)key;

- (id)idValueForKey:(NSString *)key;
- (void)setIdValue:(id)value forKey:(NSString *)key;

- (Class)classValueForKey:(NSString *)key;
- (void)setClassValue:(Class)value forKey:(NSString *)key;

- (SEL)selectorValueForKey:(NSString *)key;
- (void)setSelectorValue:(SEL)value forKey:(NSString *)key;

- (CGPoint)CGPointValueForKey:(NSString *)key;
- (void)setCGPointValue:(CGPoint)value forKey:(NSString *)key;

- (CGSize)CGSizeValueForKey:(NSString *)key;
- (void)setCGSizeValue:(CGSize)value forKey:(NSString *)key;

- (CGRect)CGRectValueForKey:(NSString *)key;
- (void)setCGRectValue:(CGRect)value forKey:(NSString *)key;

- (CGAffineTransform)CGAffineTransformValueForKey:(NSString *)key;
- (void)setCGAffineTransformValue:(CGAffineTransform)value forKey:(NSString *)key;

- (CGVector)CGVectorValueForKey:(NSString *)key;
- (void)setCGVectorValue:(CGVector)value forKey:(NSString *)key;

- (UIEdgeInsets)UIEdgeInsetsValueForKey:(NSString *)key;
- (void)setUIEdgeInsetsValue:(UIEdgeInsets)value forKey:(NSString *)key;

- (UIOffset)UIOffsetValueForKey:(NSString *)key;
- (void)setUIOffsetValue:(UIOffset)value forKey:(NSString *)key;

- (NSRange)NSRangeValueForKey:(NSString *)key;
- (void)setNSRangeValue:(NSRange)value forKey:(NSString *)key;

@end
