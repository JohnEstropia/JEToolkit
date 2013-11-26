//
//  JEDispatch.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"


/*! Dispatches a block to a concurrent global queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_global_queue()
 */
JE_EXTERN_INLINE JE_NONNULL_ALL
void JEDispatchConcurrent(dispatch_block_t block);

/*! Dispatches a block to a concurrent global queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_global_queue()
 */
JE_EXTERN_INLINE JE_NONNULL(2)
void JEDispatchConcurrentAfter(NSTimeInterval delay, dispatch_block_t block);

/*! Dispatches a block to the main queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_main_queue()
 */
JE_EXTERN_INLINE JE_NONNULL_ALL
void JEDispatchUI(dispatch_block_t block);

/*! Dispatches a block to the main queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_main_queue()
 */
JE_EXTERN_INLINE JE_NONNULL(2)
void JEDispatchUIAfter(NSTimeInterval delay, dispatch_block_t block);

/*! Dispatches a block to the main queue, or runs the block immediately if already running on the main thread.
 */
JE_EXTERN_INLINE JE_NONNULL_ALL
void JEDispatchUIASAP(dispatch_block_t block);

/*! Dispatches a block to a serial queue unique to an owning instance object. Each owner can only have one serial queue. Call JEDispatchSerial with the same owner each time to dispatch blocks to the same queue.
 */
JE_EXTERN JE_NONNULL_ALL
void JEDispatchSerial(id owner, dispatch_block_t block);
