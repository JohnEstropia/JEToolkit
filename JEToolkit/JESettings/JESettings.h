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

/*! JESettings is an abstract class for implementing getters and setters for dynamic properties. To use, subclass and declare dynamic properties (@dynamic in Obj-C, @NSManaged in Swift).
 */
@interface JESettings : NSObject

- (long long int)integerValueForKey:(nonnull NSString *)key;
- (void)setIntegerValue:(long long int)value forKey:(nonnull NSString *)key;

- (unsigned long long int)unsignedIntegerValueForKey:(nonnull NSString *)key;
- (void)setUnsignedIntegerValue:(unsigned long long int)value forKey:(nonnull NSString *)key;

- (bool)booleanValueForKey:(nonnull NSString *)key;
- (void)setBooleanValue:(bool)value forKey:(nonnull NSString *)key;

- (float)floatValueForKey:(nonnull NSString *)key;
- (void)setFloatValue:(float)value forKey:(nonnull NSString *)key;

- (double)doubleValueForKey:(nonnull NSString *)key;
- (void)setDoubleValue:(double)value forKey:(nonnull NSString *)key;

- (nullable NSString *)NSStringValueForKey:(nonnull NSString *)key;
- (void)setNSStringValue:(nullable NSString *)value forKey:(nonnull NSString *)key;

- (nullable NSNumber *)NSNumberValueForKey:(nonnull NSString *)key;
- (void)setNSNumberValue:(nullable NSNumber *)value forKey:(nonnull NSString *)key;

- (nullable NSDate *)NSDateValueForKey:(nonnull NSString *)key;
- (void)setNSDateValue:(nullable NSDate *)value forKey:(nonnull NSString *)key;

- (nullable NSData *)NSDataValueForKey:(nonnull NSString *)key;
- (void)setNSDataValue:(nullable NSData *)value forKey:(nonnull NSString *)key;

- (nullable NSURL *)NSURLValueForKey:(nonnull NSString *)key;
- (void)setNSURLValue:(nullable NSURL *)value forKey:(nonnull NSString *)key;

- (nullable NSUUID *)NSUUIDValueForKey:(nonnull NSString *)key;
- (void)setNSUUIDValue:(nullable NSUUID *)value forKey:(nonnull NSString *)key;

- (nullable id<NSCoding>)NSCodingValueForKey:(nonnull NSString *)key;
- (void)setNSCodingValue:(nullable id<NSCoding>)value forKey:(nonnull NSString *)key;

- (nullable id)idValueForKey:(nonnull NSString *)key;
- (void)setIdValue:(nullable id)value forKey:(nonnull NSString *)key;

- (nullable Class)classValueForKey:(nonnull NSString *)key;
- (void)setClassValue:(nullable Class)value forKey:(nonnull NSString *)key;

- (nullable SEL)selectorValueForKey:(nonnull NSString *)key;
- (void)setSelectorValue:(nullable SEL)value forKey:(nonnull NSString *)key;

- (CGPoint)CGPointValueForKey:(nonnull NSString *)key;
- (void)setCGPointValue:(CGPoint)value forKey:(nonnull NSString *)key;

- (CGSize)CGSizeValueForKey:(nonnull NSString *)key;
- (void)setCGSizeValue:(CGSize)value forKey:(nonnull NSString *)key;

- (CGRect)CGRectValueForKey:(nonnull NSString *)key;
- (void)setCGRectValue:(CGRect)value forKey:(nonnull NSString *)key;

- (CGAffineTransform)CGAffineTransformValueForKey:(nonnull NSString *)key;
- (void)setCGAffineTransformValue:(CGAffineTransform)value forKey:(nonnull NSString *)key;

- (CGVector)CGVectorValueForKey:(nonnull NSString *)key;
- (void)setCGVectorValue:(CGVector)value forKey:(nonnull NSString *)key;

- (UIEdgeInsets)UIEdgeInsetsValueForKey:(nonnull NSString *)key;
- (void)setUIEdgeInsetsValue:(UIEdgeInsets)value forKey:(nonnull NSString *)key;

- (UIOffset)UIOffsetValueForKey:(nonnull NSString *)key;
- (void)setUIOffsetValue:(UIOffset)value forKey:(nonnull NSString *)key;

- (NSRange)NSRangeValueForKey:(nonnull NSString *)key;
- (void)setNSRangeValue:(NSRange)value forKey:(nonnull NSString *)key;

@end
