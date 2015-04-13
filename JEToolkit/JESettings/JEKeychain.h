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

/*! The JEKeychain provides an interface for synthesizing dynamic properties by reading from/saving to the keychain. To use, subclass JEKeychain and declare dynamic properties (@dynamic in Obj-C, @NSManaged in Swift).
 */
@interface JEKeychain : JESettings

/*! Returns an instance that saves values to the keychain with kSecAttrService = <App bundle ID> and kSecAttrAccessGroup = nil. Calling -init on the same class will return the same instance.
 */
- (nonnull instancetype)init;

/*! Returns an instance that saves values to the keychain with the specified service and access group. Calling -init on the same class will return the same instance.
 @param service the value for the kSecAttrService key. Defaults to the app bundle identifier.
 @param accessGroupOrNil the value for the kSecAttrAccessGroup key. Defaults to nil.
 */
- (nonnull instancetype)initWithService:(nonnull NSString *)service
                            accessGroup:(nullable NSString *)accessGroupOrNil NS_DESIGNATED_INITIALIZER;

/*! Override to change the default string key to use as kSecAttrAccount key for a property. By default, the property name itself is used as kSecAttrAccount.
 */
- (nonnull NSString *)keychainAccountForProperty:(nonnull NSString *)propertyName;

/*! Override to change the default keychain access mode for a property. By default, returns JEKeychainAccessAfterFirstUnlock.
 */
- (JEKeychainAccess)keychainAccessForProperty:(nonnull NSString *)propertyName;

@end
