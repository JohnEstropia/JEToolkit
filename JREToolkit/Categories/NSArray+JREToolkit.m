//
//  NSArray+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSArray+JREToolkit.h"

#import "NSMutableArray+JREToolkit.h"


@implementation NSArray (JREToolkit)

#pragma mark - public

#pragma mark Container Tools

- (NSArray *)shuffledArray
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array shuffle];
    return array;
}


@end
