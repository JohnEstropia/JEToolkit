//
//  NSURL+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSURL+JEToolkit.h"

#import <MobileCoreServices/MobileCoreServices.h>


@implementation NSURL (JEToolkit)

#pragma mark - Public

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

- (BOOL)setExcludeFromBackup:(BOOL)excludeFromBackup error:(NSError *__autoreleasing *)error
{
    return [self
            setResourceValue:@(excludeFromBackup)
            forKey:NSURLIsExcludedFromBackupKey
            error:error];
}

@end
