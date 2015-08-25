//
//  NSURL+JEToolkit.m
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

#import "NSURL+JEToolkit.h"

#import <sys/xattr.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "JEAvailability.h"
#import "NSError+JEToolkit.h"
#import "NSString+JEToolkit.h"

#if __has_include("JEDebugging.h")
#import "JEDebugging.h"
#else
#define JEAssertParameter   NSCParameterAssert
#define JEAssert            NSCAssert
#endif


@implementation NSURL (JEToolkit)

#pragma mark - Private

- (const char *)je_fileSystemRepresentation NS_RETURNS_INNER_POINTER {
    
    return ([self respondsToSelector:@selector(fileSystemRepresentation)]
            ? self.fileSystemRepresentation
            : self.path.fileSystemRepresentation);
}


#pragma mark - Public

#pragma mark Directories

+ (NSURL *)applicationSupportDirectory {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSApplicationSupportDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)cachesDirectory {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSCachesDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)documentsDirectory {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)downloadsDirectory {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDownloadsDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)libraryDirectory {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSLibraryDirectory
             inDomains:NSUserDomainMask] firstObject];
}

+ (NSURL *)temporaryDirectory {
    
    return [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
}

#pragma mark Inspecting URLs

- (NSString *)UTI {
    
    return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
}

- (NSString *)mimeType {
    
    NSString *mimeType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)([self UTI]), kUTTagClassMIMEType);
    
    return (mimeType ?: @"application/octet-stream");
}

- (BOOL)isAssetsLibraryURL {
    
    return [self.scheme isEqualToString:@"assets-library"];
}

- (BOOL)isDataURL {
    
    return [self.scheme isEqualToString:@"data"];
}

- (NSDictionary<NSString *, NSString *> *)queryValues {
    
    NSArray *pairs = [self.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *components = [[NSMutableDictionary alloc] initWithCapacity:pairs.count];
    for (NSString *keyValueString in pairs) {
        
        NSArray *keyValueArray = [keyValueString componentsSeparatedByString:@"="];
        if (keyValueArray.count != 2)  {
            
            continue;
        }
        
        components[[keyValueArray[0] URLDecodedString]] = [keyValueArray[1] URLDecodedString];
    }
    return [NSDictionary dictionaryWithDictionary:components];
}

#pragma mark Extended Attributes

- (BOOL)getExtendedAttribute:(NSString *__autoreleasing *)extendedAttribute
                      forKey:(NSString *)key
                       error:(NSError *__autoreleasing *)error {
    
    JEAssertParameter([self isFileURL]);
    JEAssertParameter(![NSString isNilOrEmptyString:key]);
    JEAssert([key length] <= XATTR_MAXNAMELEN,
             @"Keys for extended attributes should be less than or equal to %d", XATTR_MAXNAMELEN);
    
    const char *keyString = [key UTF8String];
    const char *fileSystemRepresentation = [self je_fileSystemRepresentation];
    const ssize_t bufferSize = getxattr(fileSystemRepresentation,
                                        keyString,
                                        NULL,
                                        0,
                                        0,
                                        kNilOptions);
    if (bufferSize < 0) {
        
        if (extendedAttribute) {
            
            (*extendedAttribute) = nil;
        }
        if (error) {
            
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
                 kNilOptions) < 0) {
        
        free(buffer);
        
        if (extendedAttribute) {
            
            (*extendedAttribute) = nil;
        }
        if (error) {
            
            (*error) = [NSError errorWithLastPOSIXErrorAndUserInfo:@{ NSURLErrorKey : self }];
        }
        return NO;
    }
    
    NSString *attribute = [[NSString alloc]
                           initWithBytes:buffer
                           length:bufferSize
                           encoding:NSUTF8StringEncoding];
    free(buffer);
    
    if (extendedAttribute) {
        
        (*extendedAttribute) = attribute;
    }
    if (error) {
        
        (*error) = nil;
    }
    return YES;
}

- (BOOL)setExtendedAttribute:(NSString *)extendedAttribute
                      forKey:(NSString *)key
                       error:(NSError *__autoreleasing *)error {
    
    JEAssertParameter([self isFileURL]);
    JEAssertParameter(![NSString isNilOrEmptyString:key]);
    JEAssert([key length] <= XATTR_MAXNAMELEN,
             @"Keys for extended attributes should be less than or equal to %d", XATTR_MAXNAMELEN);
    
    int errorCode = 0;
    if (extendedAttribute) {
        
        const char *valueString = [extendedAttribute UTF8String];
        errorCode = setxattr([self je_fileSystemRepresentation],
                             key.UTF8String,
                             valueString,
                             strlen(valueString),
                             0,
                             kNilOptions);
    }
    else {
        
        errorCode = removexattr([self je_fileSystemRepresentation],
                                key.UTF8String,
                                kNilOptions);
    }
    
    if (!error) {
        
        return (errorCode >= 0);
    }
    
    if (errorCode < 0) {
        
        (*error) = [NSError errorWithLastPOSIXErrorAndUserInfo:@{ NSURLErrorKey : self }];
        return NO;
    }
    
    (*error) = nil;
    return YES;
}

#pragma mark Conversion

+ (NSURL *)URLFromValue:(id)valueOrNil {
    
    if (valueOrNil) {
        
        if ([valueOrNil isKindOfClass:[NSURL class]]) {
            
            return valueOrNil;
        }
        if ([valueOrNil isKindOfClass:[NSString class]]) {
            
            return [NSURL URLWithString:valueOrNil];
        }
        if ([valueOrNil isKindOfClass:[NSData class]]) {
            
            return [NSURL URLWithString:[[NSString alloc] initWithData:valueOrNil encoding:NSUTF8StringEncoding]];
        }
    }
    return nil;
}


@end
