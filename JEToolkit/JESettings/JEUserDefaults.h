//
//  JEUserDefaults.h
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

#import "JESettings.h"


@interface JEUserDefaults : JESettings

- (instancetype)init;
- (instancetype)initWithSuiteName:(NSString *)suiteName;

- (void)setDefaultIntegerValue:(long long int)value forProperty:(NSString *)propertyName;
- (void)setDefaultUnsignedIntegerValue:(unsigned long long int)value forProperty:(NSString *)propertyName;
- (void)setDefaultBooleanValue:(bool)value forProperty:(NSString *)propertyName;
- (void)setDefaultFloatValue:(float)value forProperty:(NSString *)propertyName;
- (void)setDefaultDoubleValue:(double)value forProperty:(NSString *)propertyName;
- (void)setDefaultNSStringValue:(NSString *)value forProperty:(NSString *)propertyName;
- (void)setDefaultNSNumberValue:(NSNumber *)value forProperty:(NSString *)propertyName;
- (void)setDefaultNSDataValue:(NSData *)value forProperty:(NSString *)propertyName;
- (void)setDefaultNSURLValue:(NSURL *)value forProperty:(NSString *)propertyName;
- (void)setDefaultNSUUIDValue:(NSUUID *)value forProperty:(NSString *)propertyName;
- (void)setDefaultNSCodingValue:(id<NSCoding>)value forProperty:(NSString *)propertyName;
- (void)setDefaultIdValue:(id)value forProperty:(NSString *)propertyName;
- (void)setDefaultClassValue:(Class)value forProperty:(NSString *)propertyName;
- (void)setDefaultSelectorValue:(SEL)value forProperty:(NSString *)propertyName;
- (void)setDefaultCGPointValue:(CGPoint)value forProperty:(NSString *)propertyName;
- (void)setDefaultCGSizeValue:(CGSize)value forProperty:(NSString *)propertyName;
- (void)setDefaultCGRectValue:(CGRect)value forProperty:(NSString *)propertyName;
- (void)setDefaultCGAffineTransformValue:(CGAffineTransform)value forProperty:(NSString *)propertyName;
- (void)setDefaultCGVectorValue:(CGVector)value forProperty:(NSString *)propertyName;
- (void)setDefaultUIEdgeInsetsValue:(UIEdgeInsets)value forProperty:(NSString *)propertyName;
- (void)setDefaultUIOffsetValue:(UIOffset)value forProperty:(NSString *)propertyName;
- (void)setDefaultNSRangeValue:(NSRange)value forProperty:(NSString *)propertyName;

- (void)removeDefaultValueForProperty:(NSString *)propertyName;

- (void)synchronize;

- (NSString *)userDefaultsKeyForProperty:(NSString *)propertyName;

@end
