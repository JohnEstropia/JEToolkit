//
//  NSOrderedSet+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSOrderedSet+JEToolkit.h"

#import "NSMutableString+JEToolkit.h"
#import "NSObject+JEToolkit.h"


@implementation NSOrderedSet (JEToolkit)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [super debugDescription];
}


#pragma mark - NSObject+JEToolkit

- (NSString *)loggingDescription
{
    NSMutableString *description = [NSMutableString string];
    NSUInteger count = [self count];
    if (count == 1)
    {
        [description appendString:@"1 entry ["];
    }
    else
    {
        [description appendFormat:@"%lu entries [", (unsigned long)count];
        
        if (count <= 0)
        {
            [description appendString:@"]"];
            return description;
        }
    }
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            if (idx > 0)
            {
                [description appendString:@","];
            }
            
            [description appendFormat:@"\n[%lu]: ", (unsigned long)idx];
            [description appendString:[obj
                                       loggingDescriptionIncludeClass:YES
                                       includeAddress:NO]];
            
        }
        
    }];
    
    [description indentByLevel:1];
    [description appendString:@"\n]"];
    
    return description;
}

@end
