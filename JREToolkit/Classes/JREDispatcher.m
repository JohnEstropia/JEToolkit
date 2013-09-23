//
//  JREDispatcher.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JREDispatcher.h"


@implementation JREDispatcher

#pragma mark - private

+ (NSMutableSet *)dispatchIDs
{
    static NSMutableSet *dispatchIDs;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        dispatchIDs = [NSMutableSet new];
        
    });
    
    return dispatchIDs;
}

+ (dispatch_queue_t)dispatchIDManagementQueue
{
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        queue = [self createQueueWithName:@"JREDispatcher.dispatchIDManagementQueue"
                                 inBundle:[NSBundle bundleForClass:self]
                               concurrent:YES];
        
    });
    
    return queue;
}

+ (dispatch_queue_t)createQueueWithName:(NSString *)queueName
                               inBundle:(NSBundle *)bundle
                             concurrent:(BOOL)concurrent
{
    NSCParameterAssert(bundle);
    
    NSString *queueLabel = [[NSString alloc] initWithFormat:@"%@.queue.%@",
                            [(bundle ?: [NSBundle mainBundle]) bundleIdentifier],
                            (queueName ?: [[NSString alloc] initWithFormat:@"unnamed_%@", [NSUUID UUID]])];
    return dispatch_queue_create([queueLabel UTF8String],
                                 (concurrent
                                  ? DISPATCH_QUEUE_CONCURRENT
                                  : DISPATCH_QUEUE_SERIAL));
}

+ (void)queueDispatchID:(NSUUID *)dispatchID
{
    NSCParameterAssert(dispatchID);
    
    if (!dispatchID)
    {
        return;
    }
    
    dispatch_barrier_async([self dispatchIDManagementQueue], ^{
        
        [[self dispatchIDs] addObject:dispatchID];
        
    });
}

+ (BOOL)popDispatchID:(NSUUID *)dispatchID
{
    NSCParameterAssert(dispatchID);
    
    if (!dispatchID)
    {
        return NO;
    }
    
    BOOL __block exists = NO;
    dispatch_sync([self dispatchIDManagementQueue], ^{
        
        NSMutableSet *dispatchIDs = [self dispatchIDs];
        exists = [dispatchIDs containsObject:dispatchID];
        if (exists)
        {
            [dispatchIDs removeObject:dispatchID];
        }
        
    });
    return exists;
}

+ (NSUUID *)queueBlock:(void(^)(void))block
               toQueue:(dispatch_queue_t)queue
                 delay:(NSTimeInterval)delay
           cancellable:(BOOL)cancellable
{
    NSCParameterAssert(block);
    
    if (!block || !queue)
    {
        return nil;
    }
    
    NSUUID *dispatchID;
    void (^dispatchBlock)(void) = NULL;
    
    if (cancellable)
    {
        dispatchID = [[NSUUID alloc] init];
        [self queueDispatchID:dispatchID];
        
        dispatchBlock = [^{
            
            if ([self isBlockRunning:dispatchID])
            {
                block();
            }
            [self popDispatchID:dispatchID];
            
        } copy];
    }
    else
    {
        dispatchBlock = [block copy];
    }
    
    if (delay > 0.0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (double)NSEC_PER_SEC)),
                       queue,
                       dispatchBlock);
    }
    else
    {
        dispatch_async(queue, dispatchBlock);
    }
    
    return dispatchID;
}


#pragma mark - public

#pragma mark Queues

+ (dispatch_queue_t)globalQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

+ (dispatch_queue_t)mainQueue
{
    return dispatch_get_main_queue();
}

+ (dispatch_queue_t)createQueueWithName:(NSString *)queueName
                             concurrent:(BOOL)concurrent
{
    return [self createQueueWithName:queueName
                            inBundle:nil
                          concurrent:concurrent];
}

#pragma mark Common block dispatching

+ (void)queueConcurrentBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    
    [self queueWithDelay:0.0 concurrentBlock:block];
}

+ (NSUUID *)queueCancellableConcurrentBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    
    return [self queueWithDelay:0.0 cancellableConcurrentBlock:block];
}

+ (void)queueUIBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    
    [self queueWithDelay:0.0 UIBlock:block];
}

+ (NSUUID *)queueCancellableUIBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    
    return [self queueWithDelay:0.0 cancellableUIBlock:block];
}

+ (void)queueTo:(dispatch_queue_t)queue
          block:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(queue);
    
    [self queueWithDelay:0.0 toQueue:queue block:block];
}

+ (NSUUID *)queueTo:(dispatch_queue_t)queue
   cancellableBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(queue);
    
    return [self queueWithDelay:0.0 toQueue:queue cancellableBlock:block];
}


#pragma mark Delayed block dispatching

+ (void)queueWithDelay:(NSTimeInterval)delay
       concurrentBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    [self queueBlock:block
             toQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
               delay:delay
         cancellable:NO];
}

+ (NSUUID *)queueWithDelay:(NSTimeInterval)delay
cancellableConcurrentBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    return [self queueBlock:block
                    toQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                      delay:delay
                cancellable:YES];
}

+ (void)queueWithDelay:(NSTimeInterval)delay
               UIBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    [self queueBlock:block
             toQueue:dispatch_get_main_queue()
               delay:delay
         cancellable:NO];
}

+ (NSUUID *)queueWithDelay:(NSTimeInterval)delay
        cancellableUIBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    return [self queueBlock:block
                    toQueue:dispatch_get_main_queue()
                      delay:delay
                cancellable:YES];
}

+ (void)queueWithDelay:(NSTimeInterval)delay
               toQueue:(dispatch_queue_t)queue
                 block:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(queue);
    NSCParameterAssert(delay >= 0.0);
    
    [self queueBlock:block
             toQueue:queue
               delay:delay
         cancellable:NO];
}

+ (NSUUID *)queueWithDelay:(NSTimeInterval)delay
                   toQueue:(dispatch_queue_t)queue
          cancellableBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    NSCParameterAssert(queue);
    NSCParameterAssert(delay >= 0.0);
    
    return [self queueBlock:block
                    toQueue:queue
                      delay:delay
                cancellable:YES];
}

#pragma mark Cancellable block handling

+ (void)cancelBlockWithID:(NSUUID *)dispatchID
{
    NSCParameterAssert(dispatchID);
    
    if (!dispatchID)
    {
        return;
    }
    
    [self popDispatchID:dispatchID];
}

+ (BOOL)isBlockRunning:(NSUUID *)dispatchID
{
    NSCParameterAssert(dispatchID);
    
    if (!dispatchID)
    {
        return YES;
    }
    
    BOOL __block exists = NO;
    dispatch_sync([self dispatchIDManagementQueue], ^{
        
        exists = [[self dispatchIDs] containsObject:dispatchID];
        
    });
    return exists;
}


@end
