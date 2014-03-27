//
//  NSError+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSError+JEToolkit.h"

#import "NSMutableString+JEToolkit.h"
#import "NSObject+JEToolkit.h"


@implementation NSError (JEToolkit)

#pragma mark - NSObject

- (NSString *)debugDescription
{
    return [super debugDescription];
}


#pragma mark - NSObject+JEToolkit

- (NSString *)loggingDescription
{
    NSMutableString *description = [NSMutableString stringWithFormat:
                                    @"%@ (code %li)",
                                    [self domain], (long)[self code]];
    NSDictionary *userInfo = [self userInfo];
    if ([userInfo count] <= 0)
    {
        return description;
    }
    
    [description appendString:@" userInfo: {"];
    
    BOOL __block isFirstEntry = YES;
    [userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
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


#pragma mark - Public

+ (instancetype)lastPOSIXErrorWithUserInfo:(NSDictionary *)userInfo
{
    const errno_t posixErrorCode = errno;
    NSString *errorDescription = [[NSString alloc] initWithUTF8String:(strerror(posixErrorCode) ?: "")];
    NSMutableDictionary *additionalInfo = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
    
    if ([errorDescription length] > 0
        && ![additionalInfo objectForKey:NSLocalizedDescriptionKey])
    {
        additionalInfo[NSLocalizedDescriptionKey] = errorDescription;
    }
    
    return [self
            errorWithDomain:NSPOSIXErrorDomain
            code:posixErrorCode
            userInfo:additionalInfo];
}

@end
