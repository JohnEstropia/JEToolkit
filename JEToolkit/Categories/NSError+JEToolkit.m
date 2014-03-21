//
//  NSError+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSError+JEToolkit.h"

@implementation NSError (JEToolkit)

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
