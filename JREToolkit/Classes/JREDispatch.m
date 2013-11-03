//
//  JREDispatch.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JREDispatch.h"

#import <objc/runtime.h>


void JREDispatchConcurrent(dispatch_block_t block)
{
    NSCParameterAssert(block);
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void JREDispatchConcurrentAfter(NSTimeInterval delay, dispatch_block_t block)
{
    NSCParameterAssert(delay >= 0.0f);
    NSCParameterAssert(block);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (double)NSEC_PER_SEC)),
				   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
				   block);
}

void JREDispatchUI(dispatch_block_t block)
{
    NSCParameterAssert(block);
    
	dispatch_async(dispatch_get_main_queue(), block);
}

void JREDispatchUIAfter(NSTimeInterval delay, dispatch_block_t block)
{
    NSCParameterAssert(delay >= 0.0f);
    NSCParameterAssert(block);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (double)NSEC_PER_SEC)),
				   dispatch_get_main_queue(),
				   block);
}

void JREDispatchSerial(id owner, dispatch_block_t block)
{
    NSCParameterAssert(owner);
    NSCParameterAssert(block);
    
    static const void *JRESerialQueueKey = &JRESerialQueueKey;
    dispatch_queue_t serialQueue = objc_getAssociatedObject(owner, JRESerialQueueKey);
    if (!serialQueue)
    {
        serialQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        objc_setAssociatedObject(owner,
                                 JRESerialQueueKey,
                                 serialQueue,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    dispatch_async(serialQueue, block);
}

