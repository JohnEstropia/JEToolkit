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

@property (nonatomic, strong, readonly) NSMutableDictionary *cachedUserDefaultsKeys;

@end


@implementation JEUserDefaults

#pragma mark - NSObject

- (instancetype)init {
    
    self = [self initWithDomain:NSStringFromClass([self class])];
    if (!self) {
        
        return nil;
    }
    
    _cachedUserDefaultsKeys = [[NSMutableDictionary alloc] init];
    return self;
}

- (instancetype)initWithDomain:(NSString *)domain {
    
    JEAssertParameter([domain isKindOfClass:[NSString class]]);
    
    static NSMutableDictionary *sharedInstances;
    static dispatch_queue_t barrierQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstances = [[NSMutableDictionary alloc] init];
        barrierQueue = dispatch_queue_create("com.JEToolkit.JEUserDefaults.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    typeof(self) __block instance;
    dispatch_barrier_sync(barrierQueue, ^{
        
        instance = sharedInstances[domain];
        if (!instance) {
            
            instance = [super init];
            sharedInstances[domain] = instance;
        }
    });
    
    self = instance;
    return self;
}


#if __has_include("JEDebugging.h")

#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
    unsigned int numberOfProperties = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &numberOfProperties);
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:numberOfProperties];
    for (unsigned int i = 0; i < numberOfProperties; ++i) {
        
        [keys addObject:@(property_getName(properties[i]))];
    }
    free(properties);
    
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
    
    return [(NSNumber *)[[NSUserDefaults standardUserDefaults]
             objectForKey:[self cachedUserDefaultsKeyForProperty:key]] longLongValue];
}

- (void)setIntegerValue:(long long int)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSNumber numberWithLongLong:value]
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (unsigned long long int)unsignedIntegerValueForKey:(NSString *)key {
    
    return [(NSNumber *)[[NSUserDefaults standardUserDefaults]
             objectForKey:[self cachedUserDefaultsKeyForProperty:key]] unsignedLongLongValue];
}

- (void)setUnsignedIntegerValue:(unsigned long long int)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:[NSNumber numberWithUnsignedLongLong:value]
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (bool)booleanValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]
            boolForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setBooleanValue:(bool)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setBool:value
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (float)floatValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]
            floatForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setFloatValue:(float)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setFloat:value
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (double)doubleValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]
            doubleForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setDouble:value
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSString *)NSStringValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSStringValue:(NSString *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSString class]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (NSNumber *)NSNumberValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSNumberValue:(NSNumber *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSNumber class]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (NSDate *)NSDateValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSDateValue:(NSDate *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSDate class]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (NSData *)NSDataValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults]
            objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setNSDataValue:(NSData *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSData class]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (NSURL *)NSURLValueForKey:(NSString *)key {
    
    return [NSURL URLWithString:[[NSUserDefaults standardUserDefaults]
                                 objectForKey:[self cachedUserDefaultsKeyForProperty:key]]];
}

- (void)setNSURLValue:(NSURL *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSURL class]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[value absoluteString] forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (NSUUID *)NSUUIDValueForKey:(NSString *)key {
    
    return [[NSUUID alloc] initWithUUIDString:[[NSUserDefaults standardUserDefaults]
                                               objectForKey:[self cachedUserDefaultsKeyForProperty:key]]];
}

- (void)setNSUUIDValue:(NSUUID *)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if ([value isKindOfClass:[NSUUID class]]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:[value UUIDString] forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (id<NSCoding>)NSCodingValueForKey:(NSString *)key {
    
    NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setNSCodingValue:(id<NSCoding>)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
    if (data) {
        
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:userDefaultsKey];
    }
    else {
     
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (id)idValueForKey:(NSString *)key {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (void)setIdValue:(id)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if (value) {
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (Class)classValueForKey:(NSString *)key {
    
    NSString *className = [[NSUserDefaults standardUserDefaults] objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (className ? NSClassFromString(className) : Nil);
}

- (void)setClassValue:(Class)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if (value) {
        
        [[NSUserDefaults standardUserDefaults]
         setObject:NSStringFromClass(value)
         forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (SEL)selectorValueForKey:(NSString *)key {
    
    NSString *selectorName = [[NSUserDefaults standardUserDefaults] objectForKey:[self cachedUserDefaultsKeyForProperty:key]];
    return (selectorName ? NSSelectorFromString(selectorName) : NULL);
}

- (void)setSelectorValue:(SEL)value forKey:(NSString *)key {
    
    NSString *userDefaultsKey = [self cachedUserDefaultsKeyForProperty:key];
    if (value) {
        
        [[NSUserDefaults standardUserDefaults]
         setObject:NSStringFromSelector(value)
         forKey:userDefaultsKey];
    }
    else {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:userDefaultsKey];
    }
}

- (CGPoint)CGPointValueForKey:(NSString *)key {
    
    return CGPointFromString([[NSUserDefaults standardUserDefaults]
                              objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGPointValue:(CGPoint)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:NSStringFromCGPoint(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGSize)CGSizeValueForKey:(NSString *)key {
    
    return CGSizeFromString([[NSUserDefaults standardUserDefaults]
                             objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGSizeValue:(CGSize)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:NSStringFromCGSize(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGRect)CGRectValueForKey:(NSString *)key {
    
    return CGRectFromString([[NSUserDefaults standardUserDefaults]
                             objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGRectValue:(CGRect)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:NSStringFromCGRect(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGAffineTransform)CGAffineTransformValueForKey:(NSString *)key {
    
    return CGAffineTransformFromString([[NSUserDefaults standardUserDefaults]
                                        objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGAffineTransformValue:(CGAffineTransform)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:NSStringFromCGAffineTransform(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (CGVector)CGVectorValueForKey:(NSString *)key {
    
    return CGVectorFromString([[NSUserDefaults standardUserDefaults]
                               objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setCGVectorValue:(CGVector)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:NSStringFromCGVector(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (UIEdgeInsets)UIEdgeInsetsValueForKey:(NSString *)key {
    
    return UIEdgeInsetsFromString([[NSUserDefaults standardUserDefaults]
                                   objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setUIEdgeInsetsValue:(UIEdgeInsets)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:NSStringFromUIEdgeInsets(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (UIOffset)UIOffsetValueForKey:(NSString *)key {
    
    return UIOffsetFromString([[NSUserDefaults standardUserDefaults]
                               objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setUIOffsetValue:(UIOffset)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
     setObject:NSStringFromUIOffset(value)
     forKey:[self cachedUserDefaultsKeyForProperty:key]];
}

- (NSRange)NSRangeValueForKey:(NSString *)key {
    
    return NSRangeFromString([[NSUserDefaults standardUserDefaults]
                              objectForKey:[self cachedUserDefaultsKeyForProperty:key]]);
}

- (void)setNSRangeValue:(NSRange)value forKey:(NSString *)key {
    
    [[NSUserDefaults standardUserDefaults]
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

+ (void)synchronizeAllInstances {
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)userDefaultsKeyForProperty:(NSString *)propertyName {
    
    return [NSString stringWithFormat:@"%@.%@", NSStringFromClass([self class]), propertyName];
}

@end
