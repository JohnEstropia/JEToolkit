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

#import "NSString+JEToolkit.h"
#import "NSError+JEToolkit.h"

#import "JEDebugging.h"


@interface JEKeychain ()

@property (nonatomic, strong) NSString *defaultService;
@property (nonatomic, strong) NSString *defaultAccessGroup;
@property (nonatomic, assign) JEKeychainAccess defaultAccessType;

@end


@implementation JEKeychain

#pragma mark - NSObject

- (id)init {
    
    self = [super init];
    if (self) {
        
        self.defaultService = [[NSBundle mainBundle] bundleIdentifier];
        self.defaultAccessGroup = nil;
        self.defaultAccessType = JEKeychainAccessAfterFirstUnlock;
    }
    return self;
}


#pragma mark - Private

+ (JEKeychain *)sharedInstance {
    
    static JEKeychain *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[JEKeychain alloc] init];
        
    });
    return instance;
}


#pragma mark - Public

+ (NSString *)defaultService {
    
    return [self sharedInstance].defaultService;
}

+ (void)setDefaultService:(NSString *)defaultService {
    
    JEAssertParameter(defaultService != nil);
    [self sharedInstance].defaultService = (defaultService ?: [[NSBundle mainBundle] bundleIdentifier]);
}

+ (NSString *)defaultAccessGroup {
    
    return [self sharedInstance].defaultAccessGroup;
}

+ (void)setDefaultAccessGroup:(NSString *)defaultAccessGroup {
    
    [self sharedInstance].defaultAccessGroup = defaultAccessGroup;
}

+ (JEKeychainAccess)defaultAccessType {
    
    return [self sharedInstance].defaultAccessType;
}

+ (void)setDefaultAccessType:(JEKeychainAccess)defaultAccessType {
    
    JEAssertParameter(defaultAccessType >= 0
                      && defaultAccessType < _JEKeychainAccessCount);
    [self sharedInstance].defaultAccessType = defaultAccessType;
}

+ (NSString *)stringForKey:(NSString *)key {
    
    return [self stringForKey:key inAccessGroup:nil error:NULL];
}

+ (NSString *)stringForKey:(NSString *)key
             inAccessGroup:(NSString *)accessGroup
                     error:(NSError *__autoreleasing *)error {
    
    JEAssertParameter(key != nil);
    
    if (!key) {
        
        return nil;
    }
    
    JEKeychain *instance = [self sharedInstance];
    if (!accessGroup) {
        
        accessGroup = instance.defaultAccessGroup;
    }
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithDictionary:@{
        (__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
        (__bridge NSString *)kSecReturnData : @YES,
        (__bridge NSString *)kSecMatchLimit : (__bridge NSString *)kSecMatchLimitOne,
        (__bridge NSString *)kSecAttrService : instance.defaultService,
        (__bridge NSString *)kSecAttrAccount : key,
    }];
    
    if (accessGroup) {
        
        query[(__bridge NSString *)kSecAttrAccessGroup] = accessGroup;
    }
    
	CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
	if (status != errSecSuccess) {
        
        if (error) {
            
            (*error) = [NSError errorWithOSStatus:status userInfo:nil];
        }
		return nil;
	}
    
    if (error) {
        
        (*error) = nil;
    }
    
    return [[NSString alloc]
            initWithData:(__bridge_transfer NSData *)result
            encoding:NSUTF8StringEncoding];
}

+ (BOOL)setString:(NSString *)string
           forKey:(NSString *)key {
    
    return [self setString:string forKey:key inAccessGroup:nil error:NULL];
}

+ (BOOL)setString:(NSString *)string
           forKey:(NSString *)key
    inAccessGroup:(NSString *)accessGroup
            error:(NSError *__autoreleasing *)error {
    
    JEAssertParameter(key != nil);
    
    if (!key) {
        
        return NO;
    }
    
    JEKeychain *instance = [self sharedInstance];
    if (!accessGroup) {
        
        accessGroup = instance.defaultAccessGroup;
    }
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] initWithDictionary:@{
        (__bridge NSString *)kSecClass : (__bridge NSString *)kSecClassGenericPassword,
        (__bridge NSString *)kSecAttrService : instance.defaultService,
        (__bridge NSString *)kSecAttrAccount : key,
    }];
    
    if (accessGroup) {
        
        query[(__bridge NSString *)kSecAttrAccessGroup] = accessGroup;
    }
    
    if (string) {
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess) {
            
            if (error) {
                
                (*error) = [NSError errorWithOSStatus:status userInfo:nil];
            }
            return NO;
        }
        
        CFTypeRef accessibilityAttribute = NULL;
        switch (instance.defaultAccessType) {
                
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
        
        query[(__bridge NSString *)kSecAttrAccessible] = (__bridge id)accessibilityAttribute;
        
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        if (status != errSecSuccess) {
            
            if (error) {
                
                (*error) = [NSError errorWithOSStatus:status userInfo:nil];
            }
            return NO;
        }
    }
    else
    {
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
        if (status != errSecSuccess) {
            
            if (error) {
                
                (*error) = [NSError errorWithOSStatus:status userInfo:nil];
            }
            return NO;
        }
    }
    
    
    if (error) {
        
        (*error) = nil;
    }
    return YES;
}


@end
