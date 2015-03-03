//
//  JEDispatch.m
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

#import "JEDispatch.h"
#import <objc/runtime.h>

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#endif


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


