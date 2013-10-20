//
//  JREOrderedDictionary.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/19.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JREOrderedDictionary : NSMutableDictionary

- (id)firstObject;
- (id)lastObject;

- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (id)objectAtIndex:(NSUInteger)idx;

- (id)keyAtIndex:(NSUInteger)idx;
- (NSUInteger)indexOfKey:(id)key;

- (void)enumerateIndexesAndKeysAndObjectsUsingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block;
- (void)enumerateIndexesAndKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block;
- (void)enumerateIndexesAndKeysAndObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block;

@end