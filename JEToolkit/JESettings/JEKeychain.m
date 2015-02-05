//
//  JEKeychain.m
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

#import "JEKeychain.h"
#import <objc/runtime.h>

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#define JELogAlert          NSLog
#endif


@interface JEKeychain ()

@property (nonatomic, strong, readonly) NSString *service;
@property (nonatomic, strong, readonly) NSString *accessGroup;
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedKeychainAccounts;
@property (nonatomic, strong, readonly) NSMutableDictionary *cachedKeychainAccesses;

@end


@implementation JEKeychain

#pragma mark - NSObject

- (instancetype)init {
    
#if TARGET_IPHONE_SIMULATOR
    self = [self
            initWithService:@"com.JEToolkit"
            accessGroup:nil];
#else
    self = [self
            initWithService:[[NSBundle mainBundle] bundleIdentifier]
            accessGroup:nil];
#endif
    if (!self) {
        
        return nil;
    }
    
    _cachedKeychainAccounts = [[NSMutableDictionary alloc] init];
    _cachedKeychainAccesses = [[NSMutableDictionary alloc] init];
    return self;
}

- (instancetype)initWithService:(NSString *)service
                    accessGroup:(NSString *)accessGroupOrNil {
    
    JEAssertParameter([service isKindOfClass:[NSString class]]);
    JEAssertParameter(!accessGroupOrNil || [accessGroupOrNil isKindOfClass:[NSString class]]);
    
    static NSMutableDictionary *sharedInstances;
    static dispatch_queue_t barrierQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstances = [[NSMutableDictionary alloc] init];
        barrierQueue = dispatch_queue_create("com.JEToolkit.JEKeychain.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    typeof(self) __block instance;
    NSString *className = NSStringFromClass([self class]);
    dispatch_barrier_sync(barrierQueue, ^{
        
        instance = sharedInstances[className];
        if (!instance) {
            
            instance = [super init];
            instance->_service = service;
#if !TARGET_IPHONE_SIMULATOR
            instance->_accessGroup = accessGroupOrNil;
#endif
            
            sharedInstances[className] = instance;
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
         class != [JEKeychain class] && [class isSubclassOfClass:[JEKeychain class]];
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
            [description appendString:[self cachedKeychainAccountForProperty:key]];
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
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:data] longLongValue]
            : 0);
}

- (void)setIntegerValue:(long long int)value forKey:(NSString *)key {
    
    [self
     setData:[NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithLongLong:value]]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (unsigned long long int)unsignedIntegerValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:data] unsignedLongLongValue]
            : 0);
}

- (void)setUnsignedIntegerValue:(unsigned long long int)value forKey:(NSString *)key {
    
    [self
     setData:[NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithUnsignedLongLong:value]]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (bool)booleanValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    bool value = 0;
    [data getBytes:&value length:sizeof(value)];
    return value;
}

- (void)setBooleanValue:(bool)value forKey:(NSString *)key {
    
    [self
     setData:[[NSData alloc] initWithBytes:&value length:sizeof(value)]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (float)floatValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:data] floatValue]
            : 0.0f);
}

- (void)setFloatValue:(float)value forKey:(NSString *)key {
    
    [self
     setData:[NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithFloat:value]]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (double)doubleValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithData:data] doubleValue]
            : 0.0f);
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key {
    
    [self
     setData:[NSKeyedArchiver archivedDataWithRootObject:[NSNumber numberWithDouble:value]]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (NSString *)NSStringValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
            : nil);
}

- (void)setNSStringValue:(NSString *)value forKey:(NSString *)key {
    
    [self
     setData:([value isKindOfClass:[NSString class]]
              ? [value dataUsingEncoding:NSUTF8StringEncoding]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (NSNumber *)NSNumberValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setNSNumberValue:(NSNumber *)value forKey:(NSString *)key {
    
    [self
     setData:([value isKindOfClass:[NSNumber class]]
              ? [NSKeyedArchiver archivedDataWithRootObject:value]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (NSDate *)NSDateValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setNSDateValue:(NSDate *)value forKey:(NSString *)key {
    
    [self
     setData:([value isKindOfClass:[NSDate class]]
              ? [NSKeyedArchiver archivedDataWithRootObject:value]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (NSData *)NSDataValueForKey:(NSString *)key {
    
    return [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
}

- (void)setNSDataValue:(NSData *)value forKey:(NSString *)key {
    
    [self
     setData:([value isKindOfClass:[NSDate class]]
              ? value
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (NSURL *)NSURLValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setNSURLValue:(NSURL *)value forKey:(NSString *)key {
    
    [self
     setData:([value isKindOfClass:[NSURL class]]
              ? [NSKeyedArchiver archivedDataWithRootObject:value]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (NSUUID *)NSUUIDValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    if (!data) {
        
        return nil;
    }
    
    uuid_t uuid = (uuid_t){ };
    [data getBytes:&uuid length:sizeof(uuid)];
    return [[NSUUID alloc] initWithUUIDBytes:uuid];
}

- (void)setNSUUIDValue:(NSUUID *)value forKey:(NSString *)key {
    
    NSData *data;
    if ([value isKindOfClass:[NSUUID class]]) {
        
        uuid_t uuid = (uuid_t){ };
        [value getUUIDBytes:uuid];
        data = [[NSData alloc] initWithBytes:uuid length:sizeof(uuid)];
    }
    
    [self
     setData:data
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (id<NSCoding>)NSCodingValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setNSCodingValue:(id<NSCoding>)value forKey:(NSString *)key {
    
    [self
     setData:(value
              ? [NSKeyedArchiver archivedDataWithRootObject:value]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (id)idValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? [NSKeyedUnarchiver unarchiveObjectWithData:data]
            : nil);
}

- (void)setIdValue:(id)value forKey:(NSString *)key {
    
    [self
     setData:(value
              ? [NSKeyedArchiver archivedDataWithRootObject:value]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (Class)classValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? NSClassFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : Nil);
}

- (void)setClassValue:(Class)value forKey:(NSString *)key {
    
    [self
     setData:(value
              ? [NSStringFromClass(value) dataUsingEncoding:NSUTF8StringEncoding]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (SEL)selectorValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? NSSelectorFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : Nil);
}

- (void)setSelectorValue:(SEL)value forKey:(NSString *)key {
    
    [self
     setData:(value
              ? [NSStringFromSelector(value) dataUsingEncoding:NSUTF8StringEncoding]
              : nil)
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (CGPoint)CGPointValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? CGPointFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : CGPointZero);
}

- (void)setCGPointValue:(CGPoint)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromCGPoint(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (CGSize)CGSizeValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? CGSizeFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : CGSizeZero);
}

- (void)setCGSizeValue:(CGSize)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromCGSize(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (CGRect)CGRectValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? CGRectFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : CGRectZero);
}

- (void)setCGRectValue:(CGRect)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromCGRect(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (CGAffineTransform)CGAffineTransformValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? CGAffineTransformFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : (CGAffineTransform){ });
}

- (void)setCGAffineTransformValue:(CGAffineTransform)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromCGAffineTransform(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (CGVector)CGVectorValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? CGVectorFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : (CGVector){ });
}

- (void)setCGVectorValue:(CGVector)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromCGVector(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (UIEdgeInsets)UIEdgeInsetsValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? UIEdgeInsetsFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : UIEdgeInsetsZero);
}

- (void)setUIEdgeInsetsValue:(UIEdgeInsets)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromUIEdgeInsets(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (UIOffset)UIOffsetValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? UIOffsetFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : UIOffsetZero);
}

- (void)setUIOffsetValue:(UIOffset)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromUIOffset(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}

- (NSRange)NSRangeValueForKey:(NSString *)key {
    
    NSData *data = [self dataForAccount:[self cachedKeychainAccountForProperty:key]];
    return (data
            ? NSRangeFromString([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding])
            : (NSRange){ });
}

- (void)setNSRangeValue:(NSRange)value forKey:(NSString *)key {
    
    [self
     setData:[NSStringFromRange(value) dataUsingEncoding:NSUTF8StringEncoding]
     keychainAccess:[self cachedKeychainAccessForProperty:key]
     forAccount:[self cachedKeychainAccountForProperty:key]];
}


#pragma mark - Private

- (NSData *)dataForAccount:(NSString *)account {
    
    NSMutableDictionary *query =
    [[NSMutableDictionary alloc]
     initWithDictionary:@{ (__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
                           (__bridge NSString *)kSecReturnData : @YES,
                           (__bridge NSString *)kSecMatchLimit : (__bridge NSString *)kSecMatchLimitOne,
                           (__bridge NSString *)kSecAttrService : self.service,
                           (__bridge NSString *)kSecAttrAccount : account }];
    if (self.accessGroup) {
        
        query[(__bridge NSString *)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    CFTypeRef data = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    if (status != errSecSuccess && status != errSecItemNotFound) {
        
        JELogAlert(@"Failed to read account \"%@\" from keychain with error: \n%@",
                   account,
                   [[NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil] debugDescription]);
        return nil;
    }
    
    return (__bridge_transfer NSData *)data;
}

- (void)setData:(NSData *)data
 keychainAccess:(JEKeychainAccess)keychainAccess
     forAccount:(NSString *)account {
    
    NSMutableDictionary *query =
    [[NSMutableDictionary alloc]
     initWithDictionary:@{ (__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
                           (__bridge NSString *)kSecReturnAttributes : @YES,
                           (__bridge NSString *)kSecMatchLimit : (__bridge NSString *)kSecMatchLimitOne,
                           (__bridge NSString *)kSecAttrService : self.service,
                           (__bridge NSString *)kSecAttrAccount : account }];
    if (self.accessGroup) {
        
        query[(__bridge NSString *)kSecAttrAccessGroup] = self.accessGroup;
    }
    
    if (data) {
        
        CFTypeRef accessibilityAttribute = NULL;
        switch (keychainAccess) {
                
            case JEKeychainAccessWhenUnlocked:
                accessibilityAttribute = kSecAttrAccessibleWhenUnlocked;
                break;
                
            case JEKeychainAccessAfterFirstUnlock:
                accessibilityAttribute = kSecAttrAccessibleAfterFirstUnlock;
                break;
                
            case JEKeychainAccessAlways:
                accessibilityAttribute = kSecAttrAccessibleAlways;
                break;
                
            case JEKeychainAccessWhenUnlockedThisDeviceOnly:
                accessibilityAttribute = kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
                break;
                
            case JEKeychainAccessAfterFirstUnlockThisDeviceOnly:
                accessibilityAttribute = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
                break;
                
            case JEKeychainAccessAlwaysThisDeviceOnly:
                accessibilityAttribute = kSecAttrAccessibleAlwaysThisDeviceOnly;
                break;
                
            default:
                accessibilityAttribute = kSecAttrAccessibleAfterFirstUnlock;
                break;
        }
        
        CFDictionaryRef attributesRef = NULL;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&attributesRef);
        if (status == errSecSuccess) {
            
            NSDictionary *attributes = (__bridge NSDictionary *)(attributesRef);
            query[(__bridge NSString *)kSecAttrAccessGroup] = attributes[(__bridge NSString *)kSecAttrAccessGroup];
            [query removeObjectForKey:(__bridge NSString *)kSecReturnAttributes];
            [query removeObjectForKey:(__bridge NSString *)kSecMatchLimit];
            
            NSMutableDictionary *updatedAttributes = [[NSMutableDictionary alloc] init];
            updatedAttributes[(__bridge NSString *)kSecValueData] = data;
            updatedAttributes[(__bridge NSString *)kSecAttrAccessible] = (__bridge id)accessibilityAttribute;
            
            OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updatedAttributes);
            if (status != errSecSuccess) {
                
                JELogAlert(@"Failed to update account \"%@\" in keychain with error: \n%@",
                           account,
                           [[NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil] debugDescription]);
            }
        }
        else if (status == errSecItemNotFound) {
            
            NSMutableDictionary *newAttributes = [[NSMutableDictionary alloc] initWithDictionary:query];
            [newAttributes removeObjectForKey:(__bridge NSString *)kSecReturnAttributes];
            [newAttributes removeObjectForKey:(__bridge NSString *)kSecMatchLimit];
            
            newAttributes[(__bridge NSString *)kSecValueData] = data;
            newAttributes[(__bridge NSString *)kSecAttrAccessible] = (__bridge id)accessibilityAttribute;
            
            OSStatus status = SecItemAdd((__bridge CFDictionaryRef)newAttributes, NULL);
            if (status != errSecSuccess) {
                
                JELogAlert(@"Failed to add account \"%@\" to keychain with error: \n%@",
                           account,
                           [[NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil] debugDescription]);
            }
        }
        else {
            
            JELogAlert(@"Failed to set account \"%@\" in keychain with error: \n%@",
                       account,
                       [[NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil] debugDescription]);
        }
    }
    else {
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess && status != errSecItemNotFound) {
            
            JELogAlert(@"Failed to delete account \"%@\" from keychain with error: \n%@",
                       account,
                       [[NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil] debugDescription]);
        }
    }
}


#pragma mark - Private

- (NSString *)cachedKeychainAccountForProperty:(NSString *)propertyName {
    
    NSString *keychainAccount = self.cachedKeychainAccounts[propertyName];
    if (!keychainAccount) {
        
        keychainAccount = [self keychainAccountForProperty:propertyName];
        self.cachedKeychainAccounts[propertyName] = keychainAccount;
    }
    return keychainAccount;
}

- (JEKeychainAccess)cachedKeychainAccessForProperty:(NSString *)propertyName {
    
    NSNumber *keychainAccess = self.cachedKeychainAccesses[propertyName];
    if (!keychainAccess) {
        
        keychainAccess = @([self keychainAccessForProperty:propertyName]);
        self.cachedKeychainAccesses[propertyName] = keychainAccess;
    }
    return [keychainAccess integerValue];
}


#pragma mark - Public

- (NSString *)keychainAccountForProperty:(NSString *)propertyName {
    
    return propertyName;
}

- (JEKeychainAccess)keychainAccessForProperty:(NSString *)propertyName {
    
    return JEKeychainAccessAfterFirstUnlock;
}

@end
