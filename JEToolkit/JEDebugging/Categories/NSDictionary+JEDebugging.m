//
//  NSDictionary+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSDictionary+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSDictionary (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSMutableString *description = [self
                                    stringBuilderForDetailedDescriptionIncludeClass:includeClass
                                    includeAddress:includeAddress];
    NSUInteger count = [self count];
    if (count == 1)
    {
        [description appendString:@"1 entry {"];
    }
    else
    {
        [description appendFormat:@"%lu entries {", (unsigned long)count];
        
        if (count <= 0)
        {
            [description appendString:@"}"];
            return description;
        }
    }
    
    BOOL __block isFirstEntry = YES;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
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
