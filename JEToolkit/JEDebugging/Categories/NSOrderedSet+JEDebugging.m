//
//  NSOrderedSet+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSOrderedSet+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation NSOrderedSet (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    // override any existing implementation
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
    NSMutableString *description = [NSMutableString string];
    NSUInteger count = [self count];
    if (count == 1) {
        
        [description appendString:@"1 entry ["];
    }
    else {
        
        [description appendFormat:@"%lu entries [", (unsigned long)count];
        
        if (count <= 0) {
            
            [description appendString:@"]"];
            return description;
        }
    }
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            if (idx > 0) {
                
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
