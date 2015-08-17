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

@property (nonatomic, weak, readonly) JEUserDefaults *parentForProxy;
@property (nonatomic, strong, readonly) JEUserDefaults *cachedProxyForDefaultValues;

- (instancetype)initProxyForUserDefaultsWithParent:(JEUserDefaults *)parentForProxy NS_DESIGNATED_INITIALIZER;

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

- (instancetype)initProxyForUserDefaultsWithParent:(JEUserDefaults *)parentForProxy {
    
    self = [super init];
    if (!self) {
        
        return nil;
    }
    
    _parentForProxy = parentForProxy;
    
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
    
    return [(NSNumber *)[self objectForKey:[self cachedUserDefaultsKeyForProperty:key]] longLongValue];
}

- (void)setIntegerValue:(long long int)value forKey:(NSString *)key {
    
    [self
     setObject:[NSNumber numberWithLongLong:value]
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (unsigned long long int)unsignedIntegerValueForKey:(NSString *)key {
    
    return [(NSNumber *)[self objectForKey:[self cachedUserDefaultsKeyForProperty:key]] unsignedLongLongValue];
}

- (void)setUnsignedIntegerValue:(unsigned long long int)value forKey:(NSString *)key {
    
    [self
     setObject:[NSNumber numberWithUnsignedLongLong:value]
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (bool)booleanValueForKey:(NSString *)key {
    
    return [(NSNumber *)[self objectForKey:[self cachedUserDefaultsKeyForProperty:key]] boolValue];
}

- (void)setBooleanValue:(bool)value forKey:(NSString *)key {
    
    [self
     setObject:@(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (float)floatValueForKey:(NSString *)key {
    
    return [(NSNumber *)[self objectForKey:[self cachedUserDefaultsKeyForProperty:key]] floatValue];
}

- (void)setFloatValue:(float)value forKey:(NSString *)key {
    
    [self
     setObject:@(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (double)doubleValueForKey:(NSString *)key {
    
    return [(NSNumber *)[self objectForKey:[self cachedUserDefaultsKeyForProperty:key]] doubleValue];
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key {
    
    [self
     setObject:@(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSString *)NSStringValueForKey:(NSString *)key {
    
    id object = [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    if ([object isKindOfClass:[NSData class]]) {
        
        return [NSKeyedUnarchiver unarchiveObjectWithData:object];
    }
    
    return object;
}

- (void)setNSStringValue:(NSString *)value forKey:(NSString *)key {
    
    [self
     setObject:([value isKindOfClass:[NSString class]] ? value : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSNumber *)NSNumberValueForKey:(NSString *)key {
    
    return [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSNumberValue:(NSNumber *)value forKey:(NSString *)key {
    
    [self
     setObject:([value isKindOfClass:[NSNumber class]] ? value : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSDate *)NSDateValueForKey:(NSString *)key {
    
    return [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSDateValue:(NSDate *)value forKey:(NSString *)key {
    
    [self
     setObject:([value isKindOfClass:[NSDate class]] ? value : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSData *)NSDataValueForKey:(NSString *)key {
    
    return [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSDataValue:(NSData *)value forKey:(NSString *)key {
    
    [self
     setObject:([value isKindOfClass:[NSData class]] ? value : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSURL *)NSURLValueForKey:(NSString *)key {
    
    return [NSURL URLWithString:[self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]];
}

- (void)setNSURLValue:(NSURL *)value forKey:(NSString *)key {
    
    [self
     setObject:([value isKindOfClass:[NSURL class]] ? value.absoluteString : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSUUID *)NSUUIDValueForKey:(NSString *)key {
    
    return [[NSUUID alloc] initWithUUIDString:[self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]];
}

- (void)setNSUUIDValue:(NSUUID *)value forKey:(NSString *)key {
    
    [self
     setObject:([value isKindOfClass:[NSUUID class]] ? value.UUIDString : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (id<NSCoding>)NSCodingValueForKey:(NSString *)key {
    
    NSData *data = [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil);
}

- (void)setNSCodingValue:(id<NSCoding>)value forKey:(NSString *)key {
    
    [self
     setObject:(value ? [NSKeyedArchiver archivedDataWithRootObject:value] : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (id)idValueForKey:(NSString *)key {
    
    NSData *data = [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return ([data isKindOfClass:[NSData class]]
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setIdValue:(id)value forKey:(NSString *)key {
    
    [self
     setObject:(value ? [NSKeyedArchiver archivedDataWithRootObject:value] : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (Class)classValueForKey:(NSString *)key {
    
    NSString *className = [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (className ? NSClassFromString(className) : Nil);
}

- (void)setClassValue:(Class)value forKey:(NSString *)key {
    
    [self
     setObject:(value ? NSStringFromClass(value) : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (SEL)selectorValueForKey:(NSString *)key {
    
    NSString *selectorName = [self objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (selectorName ? NSSelectorFromString(selectorName) : NULL);
}

- (void)setSelectorValue:(SEL)value forKey:(NSString *)key {
    
    [self
     setObject:(value ? NSStringFromSelector(value) : nil)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGPoint)CGPointValueForKey:(NSString *)key {
    
    return CGPointFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGPointValue:(CGPoint)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromCGPoint(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGSize)CGSizeValueForKey:(NSString *)key {
    
    return CGSizeFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGSizeValue:(CGSize)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromCGSize(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGRect)CGRectValueForKey:(NSString *)key {
    
    return CGRectFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGRectValue:(CGRect)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromCGRect(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGAffineTransform)CGAffineTransformValueForKey:(NSString *)key {
    
    return CGAffineTransformFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGAffineTransformValue:(CGAffineTransform)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromCGAffineTransform(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGVector)CGVectorValueForKey:(NSString *)key {
    
    return CGVectorFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGVectorValue:(CGVector)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromCGVector(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (UIEdgeInsets)UIEdgeInsetsValueForKey:(NSString *)key {
    
    return UIEdgeInsetsFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setUIEdgeInsetsValue:(UIEdgeInsets)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromUIEdgeInsets(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (UIOffset)UIOffsetValueForKey:(NSString *)key {
    
    return UIOffsetFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setUIOffsetValue:(UIOffset)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromUIOffset(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSRange)NSRangeValueForKey:(NSString *)key {
    
    return NSRangeFromString([self objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setNSRangeValue:(NSRange)value forKey:(NSString *)key {
    
    [self
     setObject:NSStringFromRange(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}


#pragma mark - Private

- (NSString *)cachedUserDefaultsKeyForProperty:(NSString *)propertyName {
    
    JEUserDefaults *parentForProxy = self.parentForProxy;
    if (parentForProxy) {
        
        return [parentForProxy cachedUserDefaultsKeyForProperty:propertyName];
    }
    
    NSString *userDefaultsKey = self.cachedUserDefaultsKeys[propertyName];
    if (!userDefaultsKey) {
        
        userDefaultsKey = [self userDefaultsKeyForProperty:propertyName];
        self.cachedUserDefaultsKeys[propertyName] = userDefaultsKey;
    }
    return userDefaultsKey;
}

- (id)objectForKey:(NSString *)key {
    
    JEUserDefaults *parentForProxy = self.parentForProxy;
    if (!parentForProxy) {
        
        return [self.userDefaults objectForKey:key];
    }
    
    return [parentForProxy.userDefaults volatileDomainForName:NSRegistrationDomain][key];
}

- (void)setObject:(id)object forKey:(NSString *)key {
    
    JEUserDefaults *parentForProxy = self.parentForProxy;
    if (parentForProxy) {
        
        NSUserDefaults *userDefaults = parentForProxy.userDefaults;
        NSMutableDictionary *volatileDomain = [[userDefaults volatileDomainForName:NSRegistrationDomain] mutableCopy];
        if (object) {
            
            volatileDomain[key] = object;
        }
        else {
            
            [volatileDomain removeObjectForKey:key];
        }
        
        [userDefaults setVolatileDomain:volatileDomain forName:NSRegistrationDomain];
    }
    else {
        
        [self.userDefaults setObject:object forKey:key];
    }
}


#pragma mark - Public

- (instancetype)proxyForDefaultValues {

    if (self.parentForProxy) {
        
        return self;
    }
    
    if (!_cachedProxyForDefaultValues) {
        
        _cachedProxyForDefaultValues = [[[self class] alloc] initProxyForUserDefaultsWithParent:self];
    }
    return _cachedProxyForDefaultValues;
}

- (void)synchronize {
    
    JEUserDefaults *parentForProxy = self.parentForProxy;
    if (parentForProxy) {
        
        [parentForProxy synchronize];
        return;
    }
    
    [self.userDefaults synchronize];
}

- (NSString *)userDefaultsKeyForProperty:(NSString *)propertyName {
    
    JEUserDefaults *parentForProxy = self.parentForProxy;
    if (parentForProxy) {
        
        return [parentForProxy userDefaultsKeyForProperty:propertyName];
    }
    
    return [NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), propertyName];
}

@end
