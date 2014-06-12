//
//  JEOrderedDictionary.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/19.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEOrderedDictionary.h"

#import "JESafetyHelpers.h"


@interface JEOrderedDictionary ()

@property (nonatomic, strong, readonly) NSMutableDictionary *dictionary;
@property (nonatomic, strong, readonly) NSMutableOrderedSet *orderedKeys;

@end


@implementation JEOrderedDictionary

#pragma mark - NSObject

- (instancetype)init
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

- (instancetype)initWithObjects:(const __unsafe_unretained id [])objects
                        forKeys:(const __unsafe_unretained id<NSCopying> [])keys
                          count:(NSUInteger)cnt
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _dictionary = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt];
    _orderedKeys = [[NSMutableOrderedSet alloc] initWithObjects:keys count:cnt];
    
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

- (instancetype)copyWithZone:(NSZone *)zone
{
    return [self mutableCopyWithZone:zone];
}


#pragma mark - NSMutableCopying

- (instancetype)mutableCopyWithZone:(NSZone *)zone
{
    typeof(self) instance = [[[self class] allocWithZone:zone] init];
    instance->_orderedKeys = [_orderedKeys mutableCopyWithZone:zone];
    instance->_dictionary = [_dictionary mutableCopyWithZone:zone];
    return instance;
}


#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _dictionary = [[NSMutableDictionary alloc] initWithDictionary:
                   [aDecoder decodeObjectForKey:JEKeypath(typeof(self), dictionary)]];
    _orderedKeys = [[NSMutableOrderedSet alloc] initWithOrderedSet:
                    [aDecoder decodeObjectForKey:JEKeypath(typeof(self), orderedKeys)]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.dictionary forKey:JEKeypath(typeof(self), dictionary)];
    [aCoder encodeObject:self.orderedKeys forKey:JEKeypath(typeof(self), orderedKeys)];
}


#pragma mark - Public

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

- (id)firstKey
{
    return [self.orderedKeys firstObject];
}

- (id)lastKey
{
    return [self.orderedKeys lastObject];
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
    [self
     enumerateIndexesAndKeysAndObjectsWithOptions:kNilOptions
     usingBlock:block];
}

- (void)enumerateIndexesAndKeysAndObjectsWithOptions:(NSEnumerationOptions)opts
                                          usingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block
{
    [self
     enumerateIndexesAndKeysAndObjectsAtIndexes:[[NSIndexSet alloc] initWithIndexesInRange:
                                                 (NSRange){ .location = 0, .length = [self count]}]
     options:opts
     usingBlock:block];
}

- (void)enumerateIndexesAndKeysAndObjectsAtIndexes:(NSIndexSet *)indexes
                                           options:(NSEnumerationOptions)opts
                                        usingBlock:(void (^)(NSUInteger idx, id key, id obj, BOOL *stop))block
{
    NSDictionary *dictionary = self.dictionary;
    [self.orderedKeys
     enumerateObjectsAtIndexes:indexes
     options:opts
     usingBlock:^(id key, NSUInteger idx, BOOL *stop) {
         
         block(idx, key, [dictionary objectForKey:key], stop);
         
     }];
}


@end
