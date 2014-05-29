//
//  NSIndexSet+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSIndexSet+JEToolkit.h"

#import "JEDebugging.h"


@implementation NSIndexSet (JEToolkit)

#pragma mark - Public

- (NSUInteger)integerAtIndex:(NSInteger)index
{
    NSUInteger count = [self count];
    if (index >= count)
    {
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

- (NSInteger)indexOfInteger:(NSUInteger)integer
{
    if (![self containsIndex:integer])
    {
        return NSNotFound;
    }
    
    __block NSInteger iteration = 0;
    __block NSInteger indexOfInteger = NSNotFound;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        if (idx == integer)
        {
            indexOfInteger = iteration;
            (*stop) = YES;
            return;
        }
        ++iteration;
        
    }];
    return indexOfInteger;
}

- (void)enumerateIntegersForIndexesUsingBlock:(void (^)(NSUInteger idx, NSUInteger integer, BOOL *stop))block
{
    JEParameterAssert(block != NULL);
    
    NSInteger __block iteration = 0;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        block(iteration, idx, stop);
        ++iteration;
        
    }];
}


@end
