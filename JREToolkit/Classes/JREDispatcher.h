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
 @param queueName An optional label for the queue. The actual label will be in the format " <bundleIdentifier>.queue.<queueName>" if queueName is non-nil, or "<bundleIdentifier>.queue.unnamed_<random UUID>" otherwise.
 @param concurrent YES if concurrent, NO if the queue should be serial.
 @return A new dispatch_queue_t object
 */
+ (dispatch_queue_t)createQueueWithName:(NSString *)queueName
                             concurrent:(BOOL)concurrent;


#pragma mark - Common block dispatching

/*! Dispatches a block concurrently.
 Equivalent to dispatch_async() on a global queue.
 @param block The block to dispatch. This argument must not be nil.
*/
+ (void)queueConcurrentBlock:(void(^)(void))block;

/*! Dispatches a cancellable block concurrently.
 Equivalent to dispatch_after() on a global queue.
 You can cancel execution of the block by calling cancelBlockWithID:, but if the block already started it is up to the block to check isBlockRunning:.
 @param block The block to dispatch. This argument must not be nil.
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueCancellableConcurrentBlock:(void(^)(void))block;

/*! Dispatches a block asynchronously on the main queue.
 Equivalent to dispatch_async() on dispatch_get_main_queue().
 @param block The block to dispatch. This argument must not be nil.
 */
+ (void)queueUIBlock:(void(^)(void))block;

/*! Dispatches a cancellable block asynchronously on the main queue.
 Equivalent to dispatch_after() on dispatch_get_main_queue().
 You can cancel execution of the block by calling cancelBlockWithID:, but if the block already started it is up to the block to check isBlockRunning:.
 @param block The block to dispatch. This argument must not be nil.
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueCancellableUIBlock:(void(^)(void))block;

/*! Dispatches a block asynchronously to a specified queue.
 Equivalent to dispatch_async().
 @param queue The queue on which to dispatch to. This argument must not be nil.
 @param block The block to dispatch. This argument must not be nil.
 */
+ (void)queueTo:(dispatch_queue_t)queue
          block:(void(^)(void))block;

/*! Dispatches a cancellable block asynchronously to a specified queue.
 Equivalent to dispatch_async().
 You can cancel execution of the block by calling cancelBlockWithID:, but if the block already started it is up to the block to check isBlockRunning:.
 @param queue The queue on which to dispatch to. This argument must not be nil.
 @param block The block to dispatch. This argument must not be nil.
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueTo:(dispatch_queue_t)queue
   cancellableBlock:(void(^)(void))block;


#pragma mark - Delayed block dispatching

/*! Dispatches a block concurrently after a delay.
 Equivalent to dispatch_after() on a global queue.
 @param delay The delay before executing the block. This argument must be non-negative.
 @param block The block to dispatch. This argument must not be nil.
 */
+ (void)queueWithDelay:(NSTimeInterval)delay
       concurrentBlock:(void(^)(void))block;

/*! Dispatches a block concurrently after a delay.
 Equivalent to dispatch_after() on a global queue.
 You can cancel execution of the block by calling cancelBlockWithID:, but if the block already started it is up to the block to check isBlockRunning:.
 @param delay The delay before executing the block. This argument must be non-negative.
 @param block The block to dispatch. This argument must not be nil.
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueWithDelay:(NSTimeInterval)delay
cancellableConcurrentBlock:(void(^)(void))block;

/*! Dispatches a block asynchronously on the main queue after a delay.
 Equivalent to dispatch_after() on dispatch_get_main_queue().
 @param delay The delay before executing the block. This argument must be non-negative.
 @param block The block to dispatch. This argument must not be nil.
 */
+ (void)queueWithDelay:(NSTimeInterval)delay
               UIBlock:(void(^)(void))block;

/*! Dispatches a block asynchronously on the main queue after a delay.
 Equivalent to dispatch_after() on dispatch_get_main_queue().
 You can cancel execution of the block by calling cancelBlockWithID:, but if the block already started it is up to the block to check isBlockRunning:.
 @param delay The delay before executing the block. This argument must be non-negative.
 @param block The block to dispatch. This argument must not be nil.
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueWithDelay:(NSTimeInterval)delay
        cancellableUIBlock:(void(^)(void))block;

/*! Dispatches a block asynchronously to a specified queue after a delay.
 Equivalent to dispatch_async().
 @param delay The delay before executing the block. This argument must be non-negative.
 @param queue The queue on which to dispatch to. This argument must not be nil.
 @param block The block to dispatch. This argument must not be nil.
 */
+ (void)queueWithDelay:(NSTimeInterval)delay
               toQueue:(dispatch_queue_t)queue
                 block:(void(^)(void))block;

/*! Dispatches a block asynchronously to a specified queue after a delay.
 Equivalent to dispatch_async().
 You can cancel execution of the block by calling cancelBlockWithID:, but if the block already started it is up to the block to check isBlockRunning:.
 @param delay The delay before executing the block. This argument must be non-negative.
 @param queue The queue on which to dispatch to. This argument must not be nil.
 @param block The block to dispatch. This argument must not be nil.
 @return The dispatchID you can pass to cancelBlockWithID:
 */
+ (NSUUID *)queueWithDelay:(NSTimeInterval)delay
                   toQueue:(dispatch_queue_t)queue
          cancellableBlock:(void(^)(void))block;


#pragma mark - Cancellable block handling

/*! Cancels execution of a block dispatched with queueCancellableAsyncBlock:, queueCancellableUIBlock:, or queueCancellableBlock:
 @param dispatchID The UUID returned by queueCancellableAsyncBlock:, queueCancellableUIBlock:, or queueCancellableBlock:. This argument must not be nil.
 */
+ (void)cancelBlockWithID:(NSUUID *)dispatchID;

/*! Usually used inside the block queued with queueCancellableAsyncBlock:, queueCancellableUIBlock:, or queueCancellableBlock: to check if the execution was cancelled by another thread.
 @param dispatchID The UUID returned by queueCancellableAsyncBlock:, queueCancellableUIBlock:, or queueCancellableBlock:. This argument must not be nil.
 @return YES if block is still running, NO if cancelBlockWithID: was called on the dispatchID or if the block was already completed
 */
+ (BOOL)isBlockRunning:(NSUUID *)dispatchID;


@end
