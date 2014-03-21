//
//  JEAssociatedObject.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/03/21.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEAssociatedObject.h"


@interface JEAssociatedObject ()

@property (nonatomic, weak, readonly) id weakObject;

@end


@implementation JEAssociatedObject

#pragma mark - Public

+ (JEAssociatedObject *)valueWithWeakObject:(id)weakObject
{
    JEAssociatedObject *value = [[JEAssociatedObject alloc] init];
    value->_weakObject = weakObject;
    return value;;
}

@end
