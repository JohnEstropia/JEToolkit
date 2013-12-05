//
//  NSError+JEToolkit.m
//  JEToolkit
//
//  Created by DIT John Estropia on 2013/12/05.
//  Copyright (c) 2013年 John Rommel Estropia. All rights reserved.
//

#import "NSError+JEToolkit.h"

@implementation NSError (JEToolkit)

#pragma mark - public

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
