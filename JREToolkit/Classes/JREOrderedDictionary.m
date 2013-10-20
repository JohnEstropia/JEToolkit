//
//  JREOrderedDictionary.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/19.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JREOrderedDictionary.h"

#import "JRESafetyMacros.h"


@interface JREOrderedDictionary ()

@property (nonatomic, strong, readonly) NSMutableDictionary *dictionary;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *orderedKeys;

@end


@implementation JREOrderedDictionary

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _dictionary = [[NSMutableDictionary alloc] init];
    _orderedKeys = [[NSMutableOrderedSet alloc] init];
    
    return self;
}

- (instancetype)initWithObjects:(const id [])objects forKeys:(const id<NSCopying> [])keys count:(NSUInteger)cnt
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _dictionary = [[NSMutableDictionary alloc]
                   initWithObjects: objects
                   forKeys: keys
                   count: cnt];
    _orderedKeys = [[NSMutableOrderedSet alloc]
                    initWithObjects: keys
                    count: cnt];
    
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _dictionary = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    _orderedKeys = [[NSMutableOrderedSet alloc] initWithCapacity:numItems];
    
    return self;
}


#pragma mark - NSDictionary

- (NSUInteger)count
{
    return [self.dictionary count];
}

- (id)objectForKey:(id)aKey
{
    return [self.dictionary objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator
{
    return [self.orderedKeys objectEnumerator];
}


#pragma mark - NSMutableDictionary

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    [self.dictionary setObject:anObject forKey:aKey];
    [self.orderedKeys addObject:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
    [self.dictionary removeObjectForKey:aKey];
    [self.orderedKeys removeObject:aKey];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return [self mutableCopyWithZone:zone];
}


#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    typeof(self) instance = [[JREOrderedDictionary allocWithZone:zone] init];
    instance->_orderedKeys = [_orderedKeys mutableCopyWithZone:zone];
    instance->_dictionary = [_dictionary mutableCopyWithZone:zone];
    return instance;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dictionary
                  forKey:KVC(JREOrderedDictionary, dictionary)];
    [aCoder encodeObject:self.orderedKeys
                  forKey:KVC(JREOrderedDictionary, orderedKeys)];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _dictionary = [aDecoder decodeObjectForKey:KVC(JREOrderedDictionary, dictionary)];
    _orderedKeys = [aDecoder decodeObjectForKey:KVC(JREOrderedDictionary, orderedKeys)];
    
    return self;
}


#pragma mark - public

- (id)firstObject
{
    return [self.dictionary objectForKey:[self.orderedKeys firstObject]];
}

- (id)lastObject
{
    return [self.dictionary objectForKey:[self.orderedKeys lastObject]];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self objectAtIndex:idx];
}

- (id)objectAtIndex:(NSUInteger)idx
{
    return [self.dictionary objectForKey:[self.orderedKeys objectAtIndex:idx]];
}

- (id)keyAtIndex:(NSUInteger)idx
{
    return [self.orderedKeys objectAtIndex:idx];
}

- (NSUInteger)indexOfKey:(id)key
{
    return [self.orderedKeys indexOfObject:key];
}

- (void)enumerateIndexesAndKeysAndObjectsUsingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block
{
    NSDictionary *dictionary = self.dictionary;
    [self.orderedKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        block(idx, obj, [dictionary objectForKey:obj], stop);

    }];
}

- (void)enumerateIndexesAndKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block
{
    NSDictionary *dictionary = self.dictionary;
    [self.orderedKeys enumerateObjectsWithOptions:opts usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        block(idx, obj, [dictionary objectForKey:obj], stop);

    }];
}

- (void)enumerateIndexesAndKeysAndObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block
{
    NSDictionary *dictionary = self.dictionary;
    [self.orderedKeys enumerateObjectsAtIndexes:s options:opts usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        block(idx, obj, [dictionary objectForKey:obj], stop);

    }];
}


@end
