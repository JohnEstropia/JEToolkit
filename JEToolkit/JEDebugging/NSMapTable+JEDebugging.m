//
//  NSMapTable+JEDebugging.m
//  JEToolkit
//
//  Created by DIT John Estropia on 2013/11/26.
//  Copyright (c) 2013年 John Rommel Estropia. All rights reserved.
//

#import "NSMapTable+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSMapTable (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress

{
    NSUInteger count = [self count];
    NSMutableString *description = [[NSMutableString alloc] initWithFormat:
                                    @"count = %lu {",
                                    (unsigned long)count];
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
        [description appendString:@"}"];
        return description;
    }
    
    BOOL isFirstEntry = YES;
    for (id key in self)
    {
        @autoreleasepool {
            
            id obj = [self objectForKey:key];
            if (!obj)
            {
                continue;
            }
            
            if (isFirstEntry)
            {
                [description appendString:@"\n["];
                isFirstEntry = NO;
            }
            else
            {
                [description appendString:@",\n["];
            }
            
            [description appendString:[key detailedDescriptionIncludeClass:NO includeAddress:NO]];
            [description appendString:@"]: "];
            [description appendString:[obj detailedDescriptionIncludeClass:YES includeAddress:NO]];
            
        }
        
    };
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}

@end
