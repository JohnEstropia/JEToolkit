//
//  NSURL+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSURL+JEToolkit.h"

#import <sys/xattr.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "JEDebugging.h"
#import "NSError+JEToolkit.h"
#import "NSString+JEToolkit.h"


@implementation NSURL (JEToolkit)

#pragma mark - Public

#pragma mark Directories

+ (NSURL *)applicationSupportDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSApplicationSupportDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)cachesDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSCachesDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)downloadsDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDownloadsDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)libraryDirectory
{
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSLibraryDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)temporaryDirectory
{
    return [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
}

#pragma mark Inspecting URLs

- (NSString *)UTI
{
    return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
}

- (NSString *)mimeType
{
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)([self UTI]), kUTTagClassMIMEType);
    
    return (mimeType ?: @"application/octet-stream");
}

- (BOOL)isAssetsLibraryURL
{
    return [[self scheme] isEqualToString:@"assets-library"];
}

- (BOOL)isDataURL
{
    return [[self scheme] isEqualToString:@"data"];
}

#pragma mark Extended Attributes

- (BOOL)getExtendedAttribute:(NSString *__autoreleasing *)extendedAttribute
                      forKey:(NSString *)key
                       error:(NSError *__autoreleasing *)error
{
    JEAssertParameter([self isFileURL]);
    JEAssertParameter(![NSString isNilOrEmptyString:key]);
    JEAssert([key length] <= XATTR_MAXNAMELEN,
             @"Keys for extended attributes should be less than or equal to %d", XATTR_MAXNAMELEN);
    
    const char *keyString = [key UTF8String];
    const char *fileSystemRepresentation = [self fileSystemRepresentation];
    const ssize_t bufferSize = getxattr(fileSystemRepresentation,
                                        keyString,
                                        NULL,
                                        0,
                                        0,
                                        kNilOptions);
    if (bufferSize < 0)
    {
        if (extendedAttribute)
        {
            (*extendedAttribute) = nil;
        }
        if (error)
        {
            (*error) = [NSError errorWithLastPOSIXErrorAndUserInfo:@{ NSURLErrorKey : self }];
        }
        return NO;
    }
    
    char *buffer = calloc(1, bufferSize);
    if (getxattr(fileSystemRepresentation,
                 keyString,
                 buffer,
                 bufferSize,
                 0,
                 kNilOptions) < 0)
    {
        free(buffer);
        
        if (extendedAttribute)
        {
            (*extendedAttribute) = nil;
        }
        if (error)
        {
            (*error) = [NSError errorWithLastPOSIXErrorAndUserInfo:@{ NSURLErrorKey : self }];
        }
        return NO;
    }
    
    NSString *attribute = [[NSString alloc]
                           initWithBytes:buffer
                           length:bufferSize
                           encoding:NSUTF8StringEncoding];
    free(buffer);
    
    if (extendedAttribute)
    {
        (*extendedAttribute) = attribute;
    }
    if (error)
    {
        (*error) = nil;
    }
    return YES;
}

- (BOOL)setExtendedAttribute:(NSString *)extendedAttribute
                      forKey:(NSString *)key
                       error:(NSError *__autoreleasing *)error
{
    JEAssertParameter([self isFileURL]);
    JEAssertParameter(![NSString isNilOrEmptyString:key]);
    JEAssert([key length] <= XATTR_MAXNAMELEN,
             @"Keys for extended attributes should be less than or equal to %d", XATTR_MAXNAMELEN);
    
    int errorCode = 0;
    if (extendedAttribute)
    {
        const char *valueString = [extendedAttribute UTF8String];
        errorCode = setxattr([self fileSystemRepresentation],
                             [key UTF8String],
                             valueString,
                             strlen(valueString),
                             0,
                             kNilOptions);
    }
    else
    {
        errorCode = removexattr([self fileSystemRepresentation],
                                [key UTF8String],
                                kNilOptions);
    }
    
    if (!error)
    {
        return (errorCode >= 0);
    }
    
    if (errorCode < 0)
    {
        (*error) = [NSError errorWithLastPOSIXErrorAndUserInfo:@{ NSURLErrorKey : self }];
        return NO;
    }
    
    (*error) = nil;
    return YES;
}


@end
