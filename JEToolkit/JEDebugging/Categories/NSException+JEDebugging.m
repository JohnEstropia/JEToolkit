//
//  NSException+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/27.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSException+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation NSException (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription
{
    NSMutableString *description = [NSMutableString stringWithString:
                                    [[self name]
                                     loggingDescriptionIncludeClass:NO
                                     includeAddress:NO]];
    [description appendString:@" {\nreason: "];
    [description appendString:[[self reason]
                               loggingDescriptionIncludeClass:NO
                               includeAddress:NO]];
    
    @autoreleasepool {
        
        NSMutableString *userInfoString = [[NSMutableString alloc] initWithString:@"{"];
        NSDictionary *exceptionUserInfo = [self userInfo];
        if ([exceptionUserInfo count] <= 0)
        {
            [userInfoString appendString:@"}"];
        }
        else
        {
            BOOL __block isFirstEntry = YES;
            [[self userInfo] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                
                @autoreleasepool {
                    
                    if (isFirstEntry)
                    {
                        [userInfoString appendString:@"\n["];
                        isFirstEntry = NO;
                    }
                    else
                    {
                        [userInfoString appendString:@",\n["];
                    }
                    
                    [userInfoString appendString:[key
                                                  loggingDescriptionIncludeClass:NO
                                                  includeAddress:NO]];
                    [userInfoString appendString:@"]: "];
                    [userInfoString appendString:[obj
                                                  loggingDescriptionIncludeClass:YES
                                                  includeAddress:NO]];
                    
                }
                
            }];
            [userInfoString indentByLevel:1];
            [userInfoString appendString:@"\n}"];
        }
        
        [description appendString:@",\nuserInfo: "];
        [description appendString:userInfoString];
        
    }
    
    @autoreleasepool {
        
        NSMutableString *callStackString = [[NSMutableString alloc] initWithString:@"["];
        [[self callStackSymbols] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            @autoreleasepool {
                
                [callStackString appendString:@"\n"];
                [callStackString appendString:[obj description]];
                
            }
            
        }];
        [callStackString indentByLevel:1];
        [callStackString appendString:@"\n]"];
        
        [description appendString:@",\ncallStackSymbols: "];
        [description appendString:callStackString];
        
    }
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}


@end
