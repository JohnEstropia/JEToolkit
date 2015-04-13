//
//  NSError+JEToolkit.m
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

#import "NSError+JEToolkit.h"


@implementation NSError (JEToolkit)

#pragma mark - Public

+ (instancetype)errorWithLastPOSIXErrorAndUserInfo:(NSDictionary *)userInfo {
    
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

+ (instancetype)errorWithOSStatus:(OSStatus)status userInfo:(NSDictionary *)userInfo {
    
    return [self
            errorWithDomain:NSOSStatusErrorDomain
            code:status
            userInfo:userInfo];
}

@end
