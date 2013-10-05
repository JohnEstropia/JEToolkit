//
//  JREDispatch.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JREToolkitDefines.h"


/*! Dispatches a block to a concurrent global queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_global_queue()
 */
JRE_EXTERN_INLINE JRE_NONNULL_ALL
void JREDispatchConcurrent(dispatch_block_t block);

/*! Dispatches a block to a concurrent global queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_global_queue()
 */
JRE_EXTERN_INLINE JRE_NONNULL(2)
void JREDispatchConcurrentAfter(NSTimeInterval delay, dispatch_block_t block);

/*! Dispatches a block to the main queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_main_queue()
 */
JRE_EXTERN_INLINE JRE_NONNULL_ALL
void JREDispatchUI(dispatch_block_t block);

/*! Dispatches a block to the main queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_main_queue()
 */
JRE_EXTERN_INLINE JRE_NONNULL(2)
void JREDispatchUIAfter(NSTimeInterval delay, dispatch_block_t block);

/*! Dispatches a block to a serial queue unique to an owning instance object. Each owner can only have one serial queue. Call JREDispatchSerial with the same owner each time to dispatch blocks to the same queue.
 */
JRE_EXTERN JRE_NONNULL_ALL
void JREDispatchSerial(id owner, dispatch_block_t block);
