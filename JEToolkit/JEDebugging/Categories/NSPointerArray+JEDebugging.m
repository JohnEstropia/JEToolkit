//
//  NSPointerArray+JEDebugging.m
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

#import "NSPointerArray+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation NSPointerArray (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    // override any existing implementation
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
    NSMutableString *description = [NSMutableString string];
    NSUInteger count = [self count];
    if (count == 1) {
        
        [description appendString:@"1 entry ["];
    }
    else {
        
        [description appendFormat:@"%lu entries [", (unsigned long)count];
        
        if (count <= 0) {
            
            [description appendString:@"]"];
            return description;
        }
    }
    
    for (NSInteger idx = 0; idx < count; ++idx) {
        
        @autoreleasepool {
            
            if (idx > 0)
            {
                [description appendString:@","];
            }
            
            const void *pointer = [self pointerAtIndex:idx];
            if (pointer)
            {
                [description appendFormat:@"\n[%lu]: (void *) <%p>", (unsigned long)idx, pointer];
            }
            else
            {
                [description appendFormat:@"\n[%lu]: (void *) NULL", (unsigned long)idx];
            }
            
        }
    }
    
    [description indentByLevel:1];
    [description appendString:@"\n]"];
    
    return description;
}


@end
