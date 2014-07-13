//
//  JEDispatch.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"

/*! Execute a block once and only once.
 */
#define JEDispatchOnce(block) \
    do { \
        static dispatch_once_t __je_dispatch_once_onceToken; \
        dispatch_once(&__je_dispatch_once_onceToken, block); \
    } while(NO)


JE_EXTERN JE_NONNULL_ALL
void JEDispatchConcurrent(dispatch_block_t block);

/*! Dispatches a block to a concurrent global queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_global_queue()
 */
JE_EXTERN JE_NONNULL_ALL
void JEDispatchConcurrent(dispatch_block_t block);

/*! Dispatches a block to a concurrent global queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_global_queue()
 */
JE_EXTERN JE_NONNULL(2)
void JEDispatchConcurrentAfter(NSTimeInterval delay, dispatch_block_t block);

/*! Dispatches a block to the main queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_main_queue()
 */
JE_EXTERN JE_NONNULL_ALL
void JEDispatchUI(dispatch_block_t block);

/*! Dispatches a block to the main queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_main_queue()
 */
JE_EXTERN JE_NONNULL(2)
void JEDispatchUIAfter(NSTimeInterval delay, dispatch_block_t block);

/*! Dispatches a block to the main queue, or runs the block immediately if already running on the main thread.
 */
JE_EXTERN JE_NONNULL_ALL
void JEDispatchUIASAP(dispatch_block_t block);
