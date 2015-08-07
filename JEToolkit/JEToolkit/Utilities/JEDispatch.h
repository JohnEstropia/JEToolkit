//
//  JEDispatch.h
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>

#ifndef JEToolkit_JEDispatch_h
#define JEToolkit_JEDispatch_h

#import "JECompilerDefines.h"


/*! Execute a block once and only once.
 */
#define JEDispatchOnce(block...) \
    do { \
        static dispatch_once_t __je_dispatch_once_onceToken; \
        dispatch_once(&__je_dispatch_once_onceToken, (block)); \
    } while(NO)


/*! Dispatches a block to a concurrent global queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_global_queue()
 */
JE_EXTERN
void JEDispatchConcurrent(dispatch_block_t _Nonnull block);

/*! Dispatches a block to a concurrent global queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_global_queue()
 */
JE_EXTERN
void JEDispatchConcurrentAfter(NSTimeInterval delay, dispatch_block_t _Nonnull block);

/*! Dispatches a block to the main queue. Convenience method equivalent to calling dispatch_async() with dispatch_get_main_queue()
 */
JE_EXTERN
void JEDispatchUI(dispatch_block_t _Nonnull block);

/*! Dispatches a block to the main queue after a delay. Convenience method equivalent to calling dispatch_after() with dispatch_get_main_queue()
 */
JE_EXTERN
void JEDispatchUIAfter(NSTimeInterval delay, dispatch_block_t _Nonnull block);

/*! Dispatches a block to the main queue, or runs the block immediately if already running on the main thread.
 */
JE_EXTERN
void JEDispatchUIASAP(dispatch_block_t _Nonnull block);


#endif
