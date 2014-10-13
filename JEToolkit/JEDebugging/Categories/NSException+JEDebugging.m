//
//  NSException+JEDebugging.m
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "NSException+JEDebugging.h"

#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation NSException (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    // override any existing implementation
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
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
