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


void JEDispatchConcurrent(void (^block)(void)) {
    
    JEAssertParameter(block != NULL);
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{ @autoreleasepool { block(); } });
}

void JEDispatchConcurrentAfter(NSTimeInterval delay, void (^block)(void)) {
    
    JEAssertParameter(delay >= 0.0f);
    JEAssertParameter(block != NULL);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (typeof(delay))NSEC_PER_SEC)),
				   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
				   ^{ @autoreleasepool { block(); } });
}

void JEDispatchUI(void (^block)(void)) {
    
    JEAssertParameter(block != NULL);
    
	dispatch_async(dispatch_get_main_queue(),
                   ^{ @autoreleasepool { block(); } });
}

void JEDispatchUIAfter(NSTimeInterval delay, void (^block)(void)) {
    
    JEAssertParameter(delay >= 0.0f);
    JEAssertParameter(block != NULL);
    
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (delay * (typeof(delay))NSEC_PER_SEC)),
				   dispatch_get_main_queue(),
				   ^{ @autoreleasepool { block(); } });
}

void JEDispatchUIASAP(void (^block)(void)) {
    
    JEAssertParameter(block != NULL);
    
    if ([NSThread isMainThread]) {
        
        @autoreleasepool { block(); }
    }
    else {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{ @autoreleasepool { block(); } });
    }
}

