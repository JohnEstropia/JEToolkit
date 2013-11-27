//
//  NSException+JEDebugging.m
//  JEToolkit
//
//  Created by DIT John Estropia on 2013/11/27.
//  Copyright (c) 2013年 John Rommel Estropia. All rights reserved.
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
            
            if (idx > 0)
            {
                [callStackString appendString:@",\n"];
            }
            else
            {
                [callStackString appendString:@"\n"];
            }
            [callStackString appendString:[obj detailedDescriptionIncludeClass:NO includeAddress:NO]];
            
        }
        
    }];
    [callStackString indentByLevel:1];
    [callStackString appendString:@"\n]"];
    
    NSMutableString *description = [[NSMutableString alloc] initWithFormat:
                                    @"%@ {\nreason: ",
                                    [[self name] detailedDescriptionIncludeClass:NO includeAddress:NO]];
    if (includeAddress)
    {
        [description insertString:[NSString stringWithFormat:@"<%p> ", self] atIndex:0];
    }
    if (includeClass)
    {
        [description insertString:[NSString stringWithFormat:@"(%@ *) ", [self class]] atIndex:0];
    }
    
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
