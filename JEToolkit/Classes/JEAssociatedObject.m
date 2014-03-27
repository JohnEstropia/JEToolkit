//
//  JEAssociatedObject.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2014/03/21.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEAssociatedObject.h"


@interface _JEWeakValue : NSValue

@property (nonatomic, weak, readonly) id weakObject;

- (instancetype)initWithWeakObject:(id)weakObject;

@end


@implementation _JEWeakValue

- (instancetype)initWithWeakObject:(id)weakObject
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


@implementation NSValue (JEAssociatedObject)

#pragma mark - Public

+ (NSValue *)valueWithWeakObject:(id)weakObject
{
    return [[_JEWeakValue alloc] initWithWeakObject:weakObject];
}

- (id)weakObject
{
    if ([self isKindOfClass:[_JEWeakValue class]])
    {
        return ((_JEWeakValue *)self).weakObject;
    }
    return nil;
}

@end
