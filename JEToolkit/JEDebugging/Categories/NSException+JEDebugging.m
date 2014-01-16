//
//  NSException+JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/27.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSException+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"


@implementation NSException (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
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
                
                [userInfoString appendString:[key detailedDescriptionIncludeClass:NO includeAddress:NO]];
                [userInfoString appendString:@"]: "];
                [userInfoString appendString:[obj detailedDescriptionIncludeClass:YES includeAddress:NO]];
                
            }
            
        }];
        [userInfoString indentByLevel:1];
        [userInfoString appendString:@"\n}"];
    }
    
    NSMutableString *callStackString = [[NSMutableString alloc] initWithString:@"["];
    [[self callStackSymbols] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            [callStackString appendString:@"\n"];
            [callStackString appendString:[obj description]];
            
        }
        
    }];
    [callStackString indentByLevel:1];
    [callStackString appendString:@"\n]"];
    
    NSMutableString *description = [self
                                    stringBuilderForDetailedDescriptionIncludeClass:includeClass
                                    includeAddress:includeAddress];
    [description appendString:[[self name] detailedDescriptionIncludeClass:NO includeAddress:NO]];
    [description appendString:@" {\nreason: "];
    [description appendString:[[self reason] detailedDescriptionIncludeClass:NO includeAddress:NO]];
    [description appendString:@",\nuserInfo: "];
    [description appendString:userInfoString];
    [description appendString:@",\ncallStackSymbols: "];
    [description appendString:callStackString];
    
    [description indentByLevel:1];
    [description appendString:@"\n}"];
    
    return description;
}

@end
