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

/*! The JEUserDefaults provides an interface for synthesizing dynamic properties by reading from/saving to the NSUserDefaults. To use, subclass JEUserDefaults and declare dynamic properties (@dynamic in Obj-C, @NSManaged in Swift).
 */
@interface JEUserDefaults : JESettings

/*! Returns an instance that saves values to the +[NSUserDefaults standardUserDefaults]. Calling -init on the same class and the same suiteName will return the same instance.
 */
- (nonnull instancetype)init;

/*! Returns an instance for the given suiteName. Calling -init on the same class and the same suiteName will return the same instance.
 @param suiteName the name of the app group for the NSUserDefaults. A nil suiteName will save values to the +[NSUserDefaults standardUserDefaults].
 */
- (nonnull instancetype)initWithSuiteName:(nullable NSString *)suiteName NS_DESIGNATED_INITIALIZER;

/*! Returns a proxy instance for setting default values. The instance returned by this method manages the NSRegistrationDomain domain for the original instance.
 */
- (nonnull instancetype)proxyForDefaultValues;

/*! Saves the NSUserDefaults immediately. Note that this call is not required as NSUserDefaults saves to disk periodically.
 */
- (void)synchronize;

/*! Override to change the default string key to use as NSUserDefaults key for a property. By default, keys for properties are in the format "<class name>.<property name>".
 */
- (nonnull NSString *)userDefaultsKeyForProperty:(nonnull NSString *)propertyName;

@end
