//
//  JEOrderedDictionary+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEOrderedDictionary+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation JEOrderedDictionary (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSUInteger count = [self count];
    NSMutableString *description = (count == 1
                                    ? [[NSMutableString alloc] initWithString:@"1 entry @{"]
                                    : [[NSMutableString alloc] initWithFormat:@"%lu entries @{",
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
        [description appendString:@"}"];
        return description;
    }
    
    BOOL __block isFirstEntry = YES;
    [self enumerateIndexesAndKeysAndObjectsUsingBlock:^(NSUInteger idx, id key, id obj, BOOL *stop) {
        
        @autoreleasepool {
            
            if (isFirstEntry)
            {
                [description appendString:@"\n["];
                isFirstEntry = NO;
            }
            else
            {
                [description appendString:@",\n["];
            }
            
            [description appendFormat:@"%lu: ", (unsigned long)idx];
            [description appendString:[key detailedDescriptionIncludeClass:NO includeAddress:NO]];
            [description appendString:@"]: "];
            [description appendString:[obj detailedDescriptionIncludeClass:YES includeAddress:NO]];
            
        }
        
    }];
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}

@end
