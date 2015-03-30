//
//  JEUserDefaults.m
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

#import "JEUserDefaults.h"
#import <objc/runtime.h>

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#endif


@interface JEUserDefaults ()

@property (nonatomic, strong, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedUserDefaultsKeys;

@end


@implementation JEUserDefaults

#pragma mark - NSObject

- (instancetype)init {
    
    self = [self initWithSuiteName:nil];
    return self;
}

- (instancetype)initWithSuiteName:(NSString *)suiteName {
    
    JEAssertParameter(!suiteName || [suiteName isKindOfClass:[NSString class]]);
    
    static NSMutableDictionary *sharedInstances;
    static dispatch_queue_t barrierQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstances = [[NSMutableDictionary alloc] init];
        barrierQueue = dispatch_queue_create("com.JEToolkit.JEUserDefaults.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    NSString *const instanceKey = (suiteName
                                   ? [@[NSStringFromClass([self class]), suiteName] componentsJoinedByString:@"."]
                                   : NSStringFromClass([self class]));
    typeof(self) __block instance;
    dispatch_barrier_sync(barrierQueue, ^{
        
        instance = sharedInstances[instanceKey];
        if (!instance) {
            
            instance = [super init];
            instance->_userDefaults = [[NSUserDefaults alloc] initWithSuiteName:suiteName];
            instance->_cachedUserDefaultsKeys = [[NSMutableDictionary alloc] init];
            sharedInstances[instanceKey] = instance;
        }
    });
    
    self = instance;
    return self;
}


#if __has_include("JEDebugging.h")

#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (Class class = [self class];
         class != [JEUserDefaults class] && [class isSubclassOfClass:[JEUserDefaults class]];
         class = [class superclass]) {
        
        unsigned int numberOfProperties = 0;
        objc_property_t *properties = class_copyPropertyList(class, &numberOfProperties);
        for (unsigned int i = 0; i < numberOfProperties; ++i) {
            
            [keys addObject:@(property_getName(properties[i]))];
        }
        free(properties);
    }
    
    NSMutableString *description = [NSMutableString stringWithString:@"{"];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            [description appendString:@"\n[\""];
            [description appendString:[self cachedUserDefaultsKeyForProperty:key]];
            [description appendString:@"\"]"];
            [description appendString:@": "];
            
            id value = [self valueForKey:key];
            if (value) {
                
                [description appendString:[value
                                           loggingDescriptionIncludeClass:NO
                                           includeAddress:NO]];
            }
            else {
                
                [description appendString:@"nil"];
            }
            
            [description appendString:@","];
        }
    }];
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}

#endif


#pragma mark - JESettings

- (long long int)integerValueForKey:(NSString *)key {
    
    return [(NSNumber *)[self.userDefaults
             objectForKey:[self cachedUserDefaultsKeyForProperty:key]] longLongValue];
}

- (void)setIntegerValue:(long long int)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:[NSNumber numberWithLongLong:value]
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (unsigned long long int)unsignedIntegerValueForKey:(NSString *)key {
    
    return [(NSNumber *)[self.userDefaults
             objectForKey:[self cachedUserDefaultsKeyForProperty:key]] unsignedLongLongValue];
}

- (void)setUnsignedIntegerValue:(unsigned long long int)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:[NSNumber numberWithUnsignedLongLong:value]
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (bool)booleanValueForKey:(NSString *)key {
    
    return [self.userDefaults
            boolForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setBooleanValue:(bool)value forKey:(NSString *)key {
    
    [self.userDefaults
     setBool:value
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (float)floatValueForKey:(NSString *)key {
    
    return [self.userDefaults
            floatForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setFloatValue:(float)value forKey:(NSString *)key {
    
    [self.userDefaults
     setFloat:value
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (double)doubleValueForKey:(NSString *)key {
    
    return [self.userDefaults
            doubleForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key {
    
    [self.userDefaults
     setDouble:value
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSString *)NSStringValueForKey:(NSString *)key {
    
    return [self.userDefaults
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSStringValue:(NSString *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSString class]]) {
        
        [self.userDefaults setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (NSNumber *)NSNumberValueForKey:(NSString *)key {
    
    return [self.userDefaults
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSNumberValue:(NSNumber *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        
        [self.userDefaults setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (NSDate *)NSDateValueForKey:(NSString *)key {
    
    return [self.userDefaults
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSDateValue:(NSDate *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSDate class]]) {
        
        [self.userDefaults setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (NSData *)NSDataValueForKey:(NSString *)key {
    
    return [self.userDefaults
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSDataValue:(NSData *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSData class]]) {
        
        [self.userDefaults setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (NSURL *)NSURLValueForKey:(NSString *)key {
    
    return [NSURL URLWithString:[self.userDefaults
                                 objectForKey:[self cachedUserDefaultsKeyForProperty:key]]];
}

- (void)setNSURLValue:(NSURL *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSURL class]]) {
        
        [self.userDefaults setObject:value.absoluteString forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (NSUUID *)NSUUIDValueForKey:(NSString *)key {
    
    return [[NSUUID alloc] initWithUUIDString:[self.userDefaults
                                               objectForKey:[self cachedUserDefaultsKeyForProperty:key]]];
}

- (void)setNSUUIDValue:(NSUUID *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSUUID class]]) {
        
        [self.userDefaults setObject:value.UUIDString forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (id<NSCoding>)NSCodingValueForKey:(NSString *)key {
    
    NSData *data = [self.userDefaults dataForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setNSCodingValue:(id<NSCoding>)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if (!value) {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    if (!data) {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
        return;
    }
    
    [self.userDefaults setObject:data forKey:userDefaultsKey];
}

- (id)idValueForKey:(NSString *)key {
    
    NSData *data = [self.userDefaults dataForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setIdValue:(id)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if (!value) {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    if (!data) {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
        return;
    }
    
    [self.userDefaults setObject:data forKey:userDefaultsKey];
}

- (Class)classValueForKey:(NSString *)key {
    
    NSString *className = [self.userDefaults objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (className ? NSClassFromString(className) : Nil);
}

- (void)setClassValue:(Class)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if (value) {
        
        [self.userDefaults
         setObject:NSStringFromClass(value)
         forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (SEL)selectorValueForKey:(NSString *)key {
    
    NSString *selectorName = [self.userDefaults objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (selectorName ? NSSelectorFromString(selectorName) : NULL);
}

- (void)setSelectorValue:(SEL)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if (value) {
        
        [self.userDefaults
         setObject:NSStringFromSelector(value)
         forKey:userDefaultsKey];
    }
    else {
        
        [self.userDefaults removeObjectForKey:userDefaultsKey];
    }
}

- (CGPoint)CGPointValueForKey:(NSString *)key {
    
    return CGPointFromString([self.userDefaults
                              objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGPointValue:(CGPoint)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromCGPoint(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGSize)CGSizeValueForKey:(NSString *)key {
    
    return CGSizeFromString([self.userDefaults
                             objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGSizeValue:(CGSize)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromCGSize(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGRect)CGRectValueForKey:(NSString *)key {
    
    return CGRectFromString([self.userDefaults
                             objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGRectValue:(CGRect)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromCGRect(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGAffineTransform)CGAffineTransformValueForKey:(NSString *)key {
    
    return CGAffineTransformFromString([self.userDefaults
                                        objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGAffineTransformValue:(CGAffineTransform)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromCGAffineTransform(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGVector)CGVectorValueForKey:(NSString *)key {
    
    return CGVectorFromString([self.userDefaults
                               objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGVectorValue:(CGVector)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromCGVector(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (UIEdgeInsets)UIEdgeInsetsValueForKey:(NSString *)key {
    
    return UIEdgeInsetsFromString([self.userDefaults
                                   objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setUIEdgeInsetsValue:(UIEdgeInsets)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromUIEdgeInsets(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (UIOffset)UIOffsetValueForKey:(NSString *)key {
    
    return UIOffsetFromString([self.userDefaults
                               objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setUIOffsetValue:(UIOffset)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromUIOffset(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSRange)NSRangeValueForKey:(NSString *)key {
    
    return NSRangeFromString([self.userDefaults
                              objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setNSRangeValue:(NSRange)value forKey:(NSString *)key {
    
    [self.userDefaults
     setObject:NSStringFromRange(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}


#pragma mark - Private

- (NSString *)cachedUserDefaultsKeyForProperty:(NSString *)propertyName {
    
    NSString *userDefaultsKey = self.cachedUserDefaultsKeys[propertyName];
    if (!userDefaultsKey) {
        
        userDefaultsKey = [self userDefaultsKeyForProperty:propertyName];
        self.cachedUserDefaultsKeys[propertyName] = userDefaultsKey;
    }
    return userDefaultsKey;
}


#pragma mark - Public

- (void)setDefaultIntegerValue:(long long int)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: [NSNumber numberWithLongLong:value] }];
}

- (void)setDefaultUnsignedIntegerValue:(unsigned long long int)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: [NSNumber numberWithUnsignedLongLong:value] }];
}

- (void)setDefaultBooleanValue:(bool)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: [NSNumber numberWithBool:value] }];
}

- (void)setDefaultFloatValue:(float)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: [NSNumber numberWithFloat:value] }];
}

- (void)setDefaultDoubleValue:(double)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: [NSNumber numberWithDouble:value] }];
}

- (void)setDefaultNSStringValue:(NSString *)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    if (![value isKindOfClass:[NSString class]]) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: value }];
}

- (void)setDefaultNSNumberValue:(NSNumber *)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    if (![value isKindOfClass:[NSNumber class]]) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: value }];
}

- (void)setDefaultNSDataValue:(NSData *)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    if (![value isKindOfClass:[NSData class]]) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: value }];
}

- (void)setDefaultNSURLValue:(NSURL *)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    if (![value isKindOfClass:[NSURL class]]) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: value.absoluteString }];
}

- (void)setDefaultNSUUIDValue:(NSUUID *)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    if (![value isKindOfClass:[NSUUID class]]) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: value.UUIDString }];
}

- (void)setDefaultNSCodingValue:(id<NSCoding>)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:propertyName];
    if (!value) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    if (!data) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:@{ userDefaultsKey: data }];
}

- (void)setDefaultIdValue:(id)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:propertyName];
    if (!value) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    if (!data) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:@{ userDefaultsKey: data }];
}

- (void)setDefaultClassValue:(Class)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    if (!value) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromClass(value) }];
}

- (void)setDefaultSelectorValue:(SEL)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    if (!value) {
        
        [self removeDefaultValueForProperty:propertyName];
        return;
    }
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromSelector(value) }];
}

- (void)setDefaultCGPointValue:(CGPoint)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromCGPoint(value) }];
}

- (void)setDefaultCGSizeValue:(CGSize)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromCGSize(value) }];
}

- (void)setDefaultCGRectValue:(CGRect)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromCGRect(value) }];
}

- (void)setDefaultCGAffineTransformValue:(CGAffineTransform)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromCGAffineTransform(value) }];
}

- (void)setDefaultCGVectorValue:(CGVector)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromCGVector(value) }];
}

- (void)setDefaultUIEdgeInsetsValue:(UIEdgeInsets)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromUIEdgeInsets(value) }];
}

- (void)setDefaultUIOffsetValue:(UIOffset)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromUIOffset(value) }];
}

- (void)setDefaultNSRangeValue:(NSRange)value forProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    [self.userDefaults registerDefaults:
     @{ [self cachedUserDefaultsKeyForProperty:propertyName]: NSStringFromRange(value) }];
}

- (void)removeDefaultValueForProperty:(NSString *)propertyName {
    
    JEAssertParameter([self respondsToSelector:NSSelectorFromString(propertyName)]);
    
    NSDictionary *registeredDefaults = [self.userDefaults volatileDomainForName:NSRegistrationDomain];
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:propertyName];
    if (registeredDefaults[userDefaultsKey] != nil) {
        
        NSMutableDictionary *updatedRegisteredDefaults = [[NSMutableDictionary alloc] initWithDictionary:registeredDefaults];
        [updatedRegisteredDefaults removeObjectForKey:userDefaultsKey];
        [self.userDefaults setVolatileDomain:updatedRegisteredDefaults forName:NSRegistrationDomain];
    }
}

- (void)synchronize {
    
    [self.userDefaults synchronize];
}

- (NSString *)userDefaultsKeyForProperty:(NSString *)propertyName {
    
    return [NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), propertyName];
}

@end
