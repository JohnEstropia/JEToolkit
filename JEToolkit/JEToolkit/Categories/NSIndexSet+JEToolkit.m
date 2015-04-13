//
//  NSIndexSet+JEToolkit.m
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

#import "NSIndexSet+JEToolkit.h"

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#endif


@implementation NSIndexSet (JEToolkit)

#pragma mark - Public

- (NSUInteger)integerAtIndex:(NSInteger)index {
    
    NSUInteger count = [self count];
    if (index >= count) {
        
        [[NSException
          exceptionWithName:NSRangeException
          reason:[[NSString alloc] initWithFormat:
                  @"*** -[%@ %@]: index %li beyond bounds [0 .. %lu]",
                  NSStringFromClass([self class]),
                  NSStringFromSelector(_cmd),
                  (long)index,
                  (unsigned long)MAX(0, ((NSInteger)count - 1))]
          userInfo:nil] raise];
    }
    
    __block NSInteger integerAtIndex = NSNotFound;
    __block NSInteger iteration = 0;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        if (iteration == index)
        {
            integerAtIndex = idx;
            (*stop) = YES;
            return;
        }
        ++iteration;
        
    }];
    return integerAtIndex;
}

- (NSInteger)indexOfInteger:(NSUInteger)integer {
    
    if (![self containsIndex:integer]) {
        
        return NSNotFound;
    }
    
    __block NSInteger iteration = 0;
    __block NSInteger indexOfInteger = NSNotFound;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        if (idx == integer) {
            
            indexOfInteger = iteration;
            (*stop) = YES;
            return;
        }
        ++iteration;
        
    }];
    return indexOfInteger;
}

- (void)enumerateIntegersForIndexesUsingBlock:(void (^)(NSUInteger idx, NSUInteger integer, BOOL *stop))block {
    
    JEAssertParameter(block != NULL);
    
    NSInteger __block iteration = 0;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        block(iteration, idx, stop);
        ++iteration;
        
    }];
}


@end
