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
    
    NSString *queueLabel = [[self alloc] initWithFormat:@"%@.queue.%@",
                            [bundle bundleIdentifier],
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
    
    __block BOOL exists = NO;
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

+ (NSUUID *)queueAsyncBlock:(void(^)(void))block
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
            
            if ([self popDispatchID:dispatchID])
            {
                block();
            }
            
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

+ (void)queueAsyncBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    
    [self queueAsyncBlock:block
                  toQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    delay:0.0
              cancellable:NO];
}

+ (void)queueAsyncBlock:(void(^)(void))block
                  delay:(NSTimeInterval)delay
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    [self queueAsyncBlock:block
                  toQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    delay:delay
              cancellable:NO];
}

+ (void)queueUIBlock:(void(^)(void))block
{
    NSCParameterAssert(block);
    
    [self queueAsyncBlock:block
                  toQueue:dispatch_get_main_queue()
                    delay:0.0
              cancellable:NO];
}

+ (void)queueUIBlock:(void(^)(void))block
               delay:(NSTimeInterval)delay
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    [self queueAsyncBlock:block
                  toQueue:dispatch_get_main_queue()
                    delay:delay
              cancellable:NO];
}

+ (void)queueBlock:(void(^)(void))block
           toQueue:(dispatch_queue_t)queue
{
    NSCParameterAssert(block);
    NSCParameterAssert(queue);
    
    [self queueAsyncBlock:block
                  toQueue:queue
                    delay:0.0
              cancellable:NO];
}

+ (void)queueBlock:(void(^)(void))block
           toQueue:(dispatch_queue_t)queue
             delay:(NSTimeInterval)delay
{
    NSCParameterAssert(block);
    NSCParameterAssert(queue);
    NSCParameterAssert(delay >= 0.0);
    
    [self queueAsyncBlock:block
                  toQueue:queue
                    delay:delay
              cancellable:NO];
}

#pragma mark Cancellable block dispatching

+ (NSUUID *)queueCancellableAsyncBlock:(void(^)(void))block
                                 delay:(NSTimeInterval)delay
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    return [self queueAsyncBlock:block
                         toQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                           delay:delay
                     cancellable:YES];
}

+ (NSUUID *)queueCancellableUIBlock:(void(^)(void))block
                              delay:(NSTimeInterval)delay
{
    NSCParameterAssert(block);
    NSCParameterAssert(delay >= 0.0);
    
    return [self queueAsyncBlock:block
                         toQueue:dispatch_get_main_queue()
                           delay:delay
                     cancellable:YES];
}

+ (NSUUID *)queueCancellableBlock:(void(^)(void))block
                            toQueue:(dispatch_queue_t)queue
                              delay:(NSTimeInterval)delay
{
    NSCParameterAssert(block);
    NSCParameterAssert(queue);
    NSCParameterAssert(delay >= 0.0);
    
    return [self queueAsyncBlock:block
                         toQueue:queue
                           delay:delay
                     cancellable:YES];
}

+ (void)cancelBlockWithID:(NSUUID *)dispatchID
{
    NSCParameterAssert(dispatchID);
    
    if (!dispatchID)
    {
        return;
    }
    
    [self popDispatchID:dispatchID];
}


@end
