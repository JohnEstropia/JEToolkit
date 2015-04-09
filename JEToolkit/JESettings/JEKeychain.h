//
//  JEKeychain.h
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


typedef NS_ENUM(NSInteger, JEKeychainAccess) {
    
    JEKeychainAccessWhenUnlocked,
    JEKeychainAccessAfterFirstUnlock,
    JEKeychainAccessAlways,
    JEKeychainAccessWhenUnlockedThisDeviceOnly,
    JEKeychainAccessAfterFirstUnlockThisDeviceOnly,
    JEKeychainAccessAlwaysThisDeviceOnly
};


@interface JEKeychain : JESettings

- (nonnull instancetype)init;
- (nonnull instancetype)initWithService:(nonnull NSString *)service
                            accessGroup:(nullable NSString *)accessGroupOrNil NS_DESIGNATED_INITIALIZER;

- (nonnull NSString *)keychainAccountForProperty:(nonnull NSString *)propertyName;
- (JEKeychainAccess)keychainAccessForProperty:(nonnull NSString *)propertyName;

@end
