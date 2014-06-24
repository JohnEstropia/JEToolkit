//
//  JEKeychain.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/06/20.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, JEKeychainAccess)
{
    JEKeychainAccessWhenUnlocked = 0,
    JEKeychainAccessAfterFirstUnlock,
    JEKeychainAccessAlways,
    JEKeychainAccessWhenUnlockedThisDeviceOnly,
    JEKeychainAccessAfterFirstUnlockThisDeviceOnly,
    JEKeychainAccessAlwaysThisDeviceOnly,
    
    _JEKeychainAccessCount
};


@interface JEKeychain : NSObject

+ (NSString *)defaultService;
+ (void)setDefaultService:(NSString *)defaultService;

+ (NSString *)defaultAccessGroup;
+ (void)setDefaultAccessGroup:(NSString *)defaultAccessGroup;

+ (JEKeychainAccess)defaultAccessType;
+ (void)setDefaultAccessType:(JEKeychainAccess)defaultAccessType;

+ (NSString *)stringForKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key
             inAccessGroup:(NSString *)accessGroup
                     error:(NSError *__autoreleasing *)error;
+ (BOOL)setString:(NSString *)string
           forKey:(NSString *)key;
+ (BOOL)setString:(NSString *)string
           forKey:(NSString *)key
    inAccessGroup:(NSString *)accessGroup
            error:(NSError *__autoreleasing *)error;


@end
