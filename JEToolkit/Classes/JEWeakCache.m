//
//  JEWeakCache.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/02/02.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEWeakCache.h"

#import "JESafetyHelpers.h"


@interface JEWeakCache ()

@property (nonatomic, strong, readonly) NSMapTable *mapTable;
@property (nonatomic, strong, readonly) dispatch_queue_t barrierQueue;

@end


@implementation JEWeakCache

#pragma mark - NSObject

- (instancetype)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _mapTable = [NSMapTable strongToWeakObjectsMapTable];
    _barrierQueue = dispatch_queue_create("com.JEToolkit.JEWeakCache.barrierQueue",
                                          DISPATCH_QUEUE_CONCURRENT);
    
    return self;
}

#pragma mark - Public

- (id)objectForKey:(id)key
{
    id __block object;
    JEScopeWeak(self);
    dispatch_sync(self.barrierQueue, ^{
        
        JEScopeStrong(self);
        object = [self.mapTable objectForKey:key];
        
    });
    return object;
}

- (void)setObject:(id)obj forKey:(id)key
{
    JEScopeWeak(self);
    dispatch_barrier_async(self.barrierQueue, ^{
        
        JEScopeStrong(self);
        if (obj)
        {
            [self.mapTable setObject:obj forKey:key];
        }
        else
        {
            [self.mapTable removeObjectForKey:key];
        }
        
    });
}

- (void)removeObjectForKey:(id)key
{
    JEScopeWeak(self);
    dispatch_barrier_async(self.barrierQueue, ^{
        
        JEScopeStrong(self);
        [self.mapTable removeObjectForKey:key];
        
    });
}

- (id)objectForKeyedSubscript:(id)key
{
    return [self objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key
{
    [self setObject:obj forKey:key];
}

@end
