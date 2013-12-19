//
//  _JEAssociatedObjectsWeakWrapper.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "_JEAssociatedObjectsWeakWrapper.h"

@implementation _JEAssociatedObjectsWeakWrapper

#pragma mark - NSObject

- (id)initWithWeakObject:(id)weakObject
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _weakObject = weakObject;
    return self;
}

@end
