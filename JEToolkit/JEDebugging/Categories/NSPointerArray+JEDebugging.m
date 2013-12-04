//
//  NSPointerArray+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSPointerArray+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSPointerArray (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSUInteger count = [self count];
    NSMutableString *description = (count == 1
                                    ? [[NSMutableString alloc] initWithString:@"1 entry ["]
                                    : [[NSMutableString alloc] initWithFormat:@"%lu entries [",
                                       (unsigned long)count]);
    if (includeAddress)
    {
        [description insertString:[NSString stringWithFormat:@"<%p> ", self] atIndex:0];
    }
    if (includeClass)
    {
        [description insertString:[NSString stringWithFormat:@"(%@ *) ", [self class]] atIndex:0];
    }
    if (count <= 0)
    {
        [description appendString:@"]"];
        return description;
    }
    
    for (NSInteger idx = 0; idx < count; ++idx)
    {
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
