//
//  JEDispatch.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEDispatch.h"

#import <objc/runtime.h>

#import "JEDebugging.h"


void JEDispatchConcurrent(void (^block)(void))
{
    JEParameterAssert(block != NULL);
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

void JEDispatchConcurrentAfter(NSTimeInterval delay, void (^block)(void))
{
    JEParameterAssert(delay >= 0.0f);
    JEParameterAssert(block != NULL);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (typeof(delay))NSEC_PER_SEC)),
				   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
				   block);
}

void JEDispatchUI(void (^block)(void))
{
    JEParameterAssert(block != NULL);
    
	dispatch_async(dispatch_get_main_queue(), block);
}

void JEDispatchUIAfter(NSTimeInterval delay, void (^block)(void))
{
    JEParameterAssert(delay >= 0.0f);
    JEParameterAssert(block != NULL);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (typeof(delay))NSEC_PER_SEC)),
				   dispatch_get_main_queue(),
				   block);
}

void JEDispatchUIASAP(void (^block)(void))
{
    JEParameterAssert(block != NULL);
    
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void JEDispatchSerial(id owner, void (^block)(void))
{
    JEParameterAssert(owner != nil);
    JEParameterAssert(block != NULL);
    
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

