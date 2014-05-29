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

#pragma mark - NSObject

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


#pragma mark - NSValue

- (void)getValue:(void *)value
{
#warning TODO: test memory leaks
    id __autoreleasing weakObject = self.weakObject;
    (*(id __autoreleasing *)value) = weakObject;
}

- (const char *)objCType
{
    return (const char *)_C_UNDEF;
}

- (BOOL)isEqualToValue:(NSValue *)value
{
    return [[NSValue valueWithNonretainedObject:self.weakObject] isEqualToValue:value];
}

@end


@implementation NSValue (JEAssociatedObject)

#pragma mark - Public

+ (NSValue *)valueWithWeakObject:(id)weakObject
{
    return [[_JEWeakValue alloc] initWithWeakObject:weakObject];
}

- (id)weakObjectValue
{
    if ([self isKindOfClass:[_JEWeakValue class]])
    {
        return ((_JEWeakValue *)self).weakObject;
    }
    return nil;
}

@end
