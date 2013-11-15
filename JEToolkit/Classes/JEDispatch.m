//
//  JEDispatch.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEDispatch.h"

#import <objc/runtime.h>


void JEDispatchConcurrent(dispatch_block_t block)
{
    NSCParameterAssert(block);
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void JEDispatchConcurrentAfter(NSTimeInterval delay, dispatch_block_t block)
{
    NSCParameterAssert(delay >= 0.0f);
    NSCParameterAssert(block);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (typeof(delay))NSEC_PER_SEC)),
				   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
				   block);
}

void JEDispatchUI(dispatch_block_t block)
{
    NSCParameterAssert(block);
    
	dispatch_async(dispatch_get_main_queue(), block);
}

void JEDispatchUIAfter(NSTimeInterval delay, dispatch_block_t block)
{
    NSCParameterAssert(delay >= 0.0f);
    NSCParameterAssert(block);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (typeof(delay))NSEC_PER_SEC)),
				   dispatch_get_main_queue(),
				   block);
}

void JEDispatchSerial(id owner, dispatch_block_t block)
{
    NSCParameterAssert(owner);
    NSCParameterAssert(block);
    
    static const void *JESerialQueueKey = &JESerialQueueKey;
    dispatch_queue_t serialQueue = objc_getAssociatedObject(owner, JESerialQueueKey);
    if (!serialQueue)
    {
        serialQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
        objc_setAssociatedObject(owner,
                                 JESerialQueueKey,
                                 serialQueue,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    dispatch_async(serialQueue, block);
}

