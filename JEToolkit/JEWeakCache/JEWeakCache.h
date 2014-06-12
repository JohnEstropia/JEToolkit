//
//  JEWeakCache.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/02/02.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JEWeakCache : NSObject

/*! Returns the value associated with a given key.
 @param key An object identifying the value.
 @return The value associated with key, or nil if no value is associated with key.
 */
- (id)objectForKey:(id)key;

/*! Sets the value of the specified key in the cache.
 Unlike an NSMutableDictionary object, a cache does not copy the key objects that are put into it.
 @param obj The object to be stored in the cache.
 @param key The key with which to associate the value.
 */
- (void)setObject:(id)obj forKey:(id)key;

/*! Removes a given key and its associated value from the cache.
 Does nothing if key does not exist.
 @param key The key to remove.
 */
- (void)removeObjectForKey:(id)key;

/*! Allows key subscripting with JEWeakCache. Equivalent to -[JEWeakCache objectForKey:]
 */
- (id)objectForKeyedSubscript:(id)key;

/*! Allows key subscripting with JEWeakCache. Equivalent to -[JEWeakCache setObject:forKey:]
 */
- (void)setObject:(id)obj forKeyedSubscript:(id)key;


@end
