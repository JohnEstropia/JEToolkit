//
//  JEWeakCache.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/02/02.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEWeakCache.h"


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

- (id)objectForKeyedSubscript:(id)key
{
    id __block object;
    typeof(self) __weak weakSelf = self;
    dispatch_sync(self.barrierQueue, ^{
       
        typeof(self) strongSelf = weakSelf;
        object = [strongSelf.mapTable objectForKey:key];
        
    });
    return object;
}

- (void)setObject:(id)obj forKeyedSubscript:(id)key
{
    typeof(self) __weak weakSelf = self;
    dispatch_barrier_async(self.barrierQueue, ^{
        
        typeof(self) strongSelf = weakSelf;
        if (obj)
        {
            [strongSelf.mapTable setObject:obj forKey:key];
        }
        else
        {
            [strongSelf.mapTable removeObjectForKey:key];
        }
        
    });
}

- (void)removeObjectForKey:(id)key
{
    typeof(self) __weak weakSelf = self;
    dispatch_barrier_async(self.barrierQueue, ^{
        
        typeof(self) strongSelf = weakSelf;
        [strongSelf.mapTable removeObjectForKey:key];
        
    });
}

@end
