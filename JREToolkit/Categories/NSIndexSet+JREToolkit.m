//
//  NSIndexSet+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSIndexSet+JREToolkit.h"

@implementation NSIndexSet (JREToolkit)

#pragma mark - public

- (NSUInteger)integerAtIndex:(NSInteger)index
{
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
    __block NSInteger iteration = 0;
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        
        if (idx == integer)
        {
            (*stop) = YES;
            return;
        }
        ++iteration;
        
    }];
    return iteration;
}


@end
