//
//  JREDispatcher.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

/*! The JREDispatcher class is a wrapper to common GCD usage.
 */
@interface JREDispatcher : NSObject

#pragma mark - Queues

/*! Equivalent to dispatch_get_global_queue() with default priority.
 
 @return A new dispatch_queue_t object
 */
+ (dispatch_queue_t)globalQueue;

/*! Equivalent to dispatch_get_main_queue().
 
 @return A new dispatch_queue_t object
 */
+ (dispatch_queue_t)mainQueue;

/*! Equivalent to dispatch_queue_create().
 
 @param queueName An optional label for the queue. The actual label will be in the format " <bundleIdentifier>.queue.<queueName>" if queueName is non-nil, or "<bundleIdentifier>.queue.unnamed_<random UUID> " otherwise.
 @param concurrent YES if concurrent, NO if the queue should be serial.
 
 @return A new dispatch_queue_t object
 */
+ (dispatch_queue_t)createQueueWithName:(NSString *)queueName
                             concurrent:(BOOL)concurrent;


#pragma mark - Common block dispatching

/*! Dispatches a block asynchronously.
 Equivalent to dispatch_async() on a global queue.
 
 @param block The block to dispatch. This argument must not be nil.
*/
+ (void)queueAsyncBlock:(void(^)(void))block;

/*! Dispatches a block asynchronously after a delay.
 Equivalent to dispatch_after() on a global queue.
 
 @param block The block to dispatch. This argument must not be nil.
 @param delay The delay before executing the block. This argument must be non-negative.
 */
+ (void)queueAsyncBlock:(void(^)(void))block
                  delay:(NSTimeInterval)delay;

/*! Dispatches a block asynchronously on the main queue.
 Equivalent to dispatch_async() on dispatch_get_main_queue().
 
 @param block The block to dispatch. This argument must not be nil.
 */
+ (void)queueUIBlock:(void(^)(void))block;

/*! Dispatches a block asynchronously on the main queue after a delay.
 Equivalent to dispatch_after() on dispatch_get_main_queue().
 
 @param block The block to dispatch. This argument must not be nil.
 @param delay The delay before executing the block. This argument must be non-negative.
 */
+ (void)queueUIBlock:(void(^)(void))block
               delay:(NSTimeInterval)delay;

/*! Dispatches a block asynchronously to a specified queue.
 Equivalent to dispatch_async().
 
 @param block The block to dispatch. This argument must not be nil.
 @param queue The queue on which to dispatch to. This argument must not be nil.
 */
+ (void)queueBlock:(void(^)(void))block
           toQueue:(dispatch_queue_t)queue;

/*! Dispatches a block asynchronously to a specified queue after a delay.
 Equivalent to dispatch_async().
 
 @param block The block to dispatch. This argument must not be nil.
 @param queue The queue on which to dispatch to. This argument must not be nil.
 @param delay The delay before executing the block. This argument must be non-negative.
 */
+ (void)queueBlock:(void(^)(void))block
           toQueue:(dispatch_queue_t)queue
             delay:(NSTimeInterval)delay;


#pragma mark - Cancellable block dispatching

/*! Dispatches a block asynchronously after a delay.
 Equivalent to dispatch_after() on a global queue.
 You can cancel execution of the block by calling cancelBlockWithID:, but only if the block has not started executing yet.
 
 @param block The block to dispatch. This argument must not be nil.
 @param delay The delay before executing the block. This argument must be non-negative.
 
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueCancellableAsyncBlock:(void(^)(void))block
                                 delay:(NSTimeInterval)delay;

/*! Dispatches a block asynchronously on the main queue after a delay.
 Equivalent to dispatch_after() on dispatch_get_main_queue().
 You can cancel execution of the block by calling cancelBlockWithID:, but only if the block has not started executing yet.
 
 @param block The block to dispatch. This argument must not be nil.
 @param delay The delay before executing the block. This argument must be non-negative.
 
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueCancellableUIBlock:(void(^)(void))block
                              delay:(NSTimeInterval)delay;

/*! Dispatches a block asynchronously to a specified queue after a delay.
 Equivalent to dispatch_async().
 You can cancel execution of the block by calling cancelBlockWithID:, but only if the block has not started executing yet.
 
 @param block The block to dispatch. This argument must not be nil.
 @param queue The queue on which to dispatch to. This argument must not be nil.
 @param delay The delay before executing the block. This argument must be non-negative.
 
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueCancellableBlock:(void(^)(void))block
                          toQueue:(dispatch_queue_t)queue
                            delay:(NSTimeInterval)delay;

/*! Cancels execution of a block dispatched with queueCancellableAsyncBlock: or queueCancellableUIBlock:
 @warning Note that blocks already running cannot be cancelled anymore.
 
 @param dispatchID The UUID returned by queueCancellableAsyncBlock: or queueCancellableUIBlock:. This argument must not be nil.
 */
+ (void)cancelBlockWithID:(NSUUID *)dispatchID;

@end
