//
//  NSError+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSError+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation NSError (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    // override any existing implementation
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
    NSMutableString *description = [NSMutableString stringWithFormat:
                                    @"%@ (code %li)",
                                    [self domain], (long)[self code]];
    NSDictionary *userInfo = [self userInfo];
    if ([userInfo count] <= 0) {
        
        return description;
    }
    
    [description appendString:@" userInfo: {"];
    
    BOOL __block isFirstEntry = YES;
    [userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        @autoreleasepool {
            
            if (isFirstEntry) {
                
                [description appendString:@"\n["];
                isFirstEntry = NO;
            }
            else {
                
                [description appendString:@",\n["];
            }
            
            [description appendString:[key
                                       loggingDescriptionIncludeClass:NO
                                       includeAddress:NO]];
            [description appendString:@"]: "];
            [description appendString:[obj
                                       loggingDescriptionIncludeClass:YES
                                       includeAddress:NO]];
            
        }
        
    }];
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}


@end
