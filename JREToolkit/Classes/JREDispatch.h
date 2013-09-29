//
//  JREDispatch.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JREToolkitDefines.h"


/*! Equivalent to dqqqqqspatch_queue_create().
 @param queueName An optional label for the queue. The actual label will be in the format " <bundleIdentifier>.queue.<queueName>" if queueName is non-nil, or "<bundleIdentifier>.queue.unnamed_<random UUID>" otherwise.
 @param concurrent YES if concurrent, NO if the queue should be serial.
 @return A new dispatch_queue_t object
 */
JRE_EXTERN_INLINE JRE_NONNULL_ALL
void JREDispatchConcurrent(dispatch_block_t block);


/*! Equivalent to dispatch_queue_create().
 @param queueName An optional label for the queue. The actual label will be in the format " <bundleIdentifier>.queue.<queueName>" if queueName is non-nil, or "<bundleIdentifier>.queue.unnamed_<random UUID>" otherwise.
 @param concurrent YES if concurrent, NO if the queue should be serial.
 @return A new dispatch_queue_t object
 */
JRE_EXTERN_INLINE JRE_NONNULL(2)
void JREDispatchConcurrentAfter(NSTimeInterval delay, dispatch_block_t block);


JRE_EXTERN_INLINE JRE_NONNULL_ALL
void JREDispatchUI(dispatch_block_t block);


JRE_EXTERN_INLINE JRE_NONNULL(2)
void JREDispatchUIAfter(NSTimeInterval delay, dispatch_block_t block);


JRE_EXTERN JRE_NONNULL_ALL
void JREDispatchSerial(id owner, dispatch_block_t block);
