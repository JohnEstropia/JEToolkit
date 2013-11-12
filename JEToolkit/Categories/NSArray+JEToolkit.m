//
//  NSArray+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSArray+JEToolkit.h"

#import "NSMutableArray+JEToolkit.h"


@implementation NSArray (JEToolkit)

#pragma mark - public

#pragma mark Container Tools

- (NSArray *)shuffledArray
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self];
    [array shuffle];
    return [array copy];
}


@end
