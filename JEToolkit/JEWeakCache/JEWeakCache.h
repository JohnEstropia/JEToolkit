//
//  JEWeakCache.h
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

#import <Foundation/Foundation.h>

@interface JEWeakCache : NSObject

/*! Returns the value associated with a given key.
 @param key An object identifying the value.
 @return The value associated with key, or nil if no value is associated with key.
 */
- (nullable id)objectForKey:(nonnull id)key;

/*! Sets the value of the specified key in the cache.
 Unlike an NSMutableDictionary object, a cache does not copy the key objects that are put into it.
 @param obj The object to be stored in the cache.
 @param key The key with which to associate the value.
 */
- (void)setObject:(nullable id)obj forKey:(nonnull id)key;

/*! Removes a given key and its associated value from the cache.
 Does nothing if key does not exist.
 @param key The key to remove.
 */
- (void)removeObjectForKey:(nonnull id)key;

/*! Allows key subscripting with JEWeakCache. Equivalent to -[JEWeakCache objectForKey:]
 */
- (nullable id)objectForKeyedSubscript:(nonnull id)key;

/*! Allows key subscripting with JEWeakCache. Equivalent to -[JEWeakCache setObject:forKey:]
 */
- (void)setObject:(nullable id)obj forKeyedSubscript:(nonnull id)key;


@end
