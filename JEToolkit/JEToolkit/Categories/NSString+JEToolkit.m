//
//  NSString+JEToolkit.m
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

#import "NSString+JEToolkit.h"


@implementation NSString (JEToolkit)

#pragma mark - Public

#pragma mark Directories

+ (NSString *)applicationSupportDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)cachesDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)documentsDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)downloadsDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)libraryDirectory {
    
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)temporaryDirectory {
    
    return NSTemporaryDirectory();
}

+ (NSString *)pathWithComponents:(NSArray *)components pathExtension:(NSString *)pathExtension {
    
    NSString *path = [NSString pathWithComponents:components];
    if (pathExtension) {
        
        path = [path stringByAppendingPathExtension:pathExtension];
    }
    return path;
}

#pragma mark Constants

+ (NSString *)applicationName {
    
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
}

+ (NSString *)applicationVersion {
    
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)applicationBundleVersion {
    
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

#pragma mark String Manipulation

- (NSString *)trimmedString {
    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray *)glyphs {
    
	NSInteger length = [self length];
	NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:length];
    [self
     enumerateSubstringsInRange:(NSRange){ .location = 0, .length = length }
     options:NSStringEnumerationByComposedCharacterSequences
     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         [characters addObject:substring];
         
     }];
	return [characters copy];
}

- (NSRange)range {
    
    return (NSRange){ .location = 0, .length = [self length] };
}

#pragma mark Validation

+ (BOOL)isNilOrEmptyString:(id)valueOrNil {
    
    return (![valueOrNil isKindOfClass:[NSString class]]
            || [[(NSString *)valueOrNil trimmedString] length] <= 0);
}

+ (NSString *)nonEmptyStringOrNil:(id)valueOrNil {
    
    if (![valueOrNil isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSString *trimmedString = [(NSString *)valueOrNil trimmedString];
    return ([trimmedString length] > 0 ? trimmedString : nil);
}

- (BOOL)containsSubstring:(NSString *)substring {
    
    return [self containsSubstring:substring options:NSLiteralSearch];
}

- (BOOL)containsSubstring:(NSString *)substring
                  options:(NSStringCompareOptions)options {
    
    return (!substring
            ? NO
            : [self rangeOfString:substring options:options].location != NSNotFound);
}

- (NSComparisonResult)compareWithVersion:(NSString *)versionString {
    
    if (!versionString)
    {
        return NSOrderedDescending;
    }
    
    NSArray *components1 = [self componentsSeparatedByString:@"."];
    NSArray *components2 = [versionString componentsSeparatedByString:@"."];
    
    NSUInteger components1Count = [components1 count];
    NSUInteger components2Count = [components2 count];
    NSUInteger partCount = MAX(components1Count, components2Count);
    
    for (NSInteger part = 0; part < partCount; ++part)
    {
        if (part >= components1Count)
        {
            return NSOrderedAscending;
        }
        
        if (part >= components2Count)
        {
            return NSOrderedDescending;
        }
        
        NSString *part1String = components1[part];
        NSString *part2String = components2[part];
        NSInteger part1 = [part1String integerValue];
        NSInteger part2 = [part2String integerValue];
        
        if (part1 > part2)
        {
            return NSOrderedDescending;
        }
        if (part1 < part2)
        {
            return NSOrderedAscending;
        }
    }
    return NSOrderedSame;
}

#pragma mark Conversion

+ (NSString *)stringFromValue:(id)valueOrNil {
    
    if (valueOrNil) {
        
        if ([valueOrNil isKindOfClass:[NSString class]]) {
            
            return valueOrNil;
        }
        if ([valueOrNil isKindOfClass:[NSNumber class]]) {
            
            return [(NSNumber *)valueOrNil stringValue];
        }
        if ([valueOrNil isKindOfClass:[NSData class]]) {
            
            return [[self alloc] initWithData:valueOrNil encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

+ (NSString *)stringFromFileSize:(int64_t)fileSize {
    
	if (fileSize < 1023) {
        
		return [NSString stringWithFormat:@"%llu bytes", fileSize];
    }
    
	double decimalSize = ((double)fileSize / 1024.0);
	if (decimalSize < 1023.0) {
        
		return [NSString stringWithFormat:@"%1.1f KB", decimalSize];
    }
    
	decimalSize /= 1024.0;
	if (decimalSize < 1023.0) {
        
		return [NSString stringWithFormat:@"%1.1f MB", decimalSize];
    }
    
	decimalSize /= 1024.0;
    return [NSString stringWithFormat:@"%1.1f GB", decimalSize];
}

- (NSString *)canonicalString
{
    return [[self trimmedString] lowercaseString];
}

- (NSString *)URLEncodedString {
    
    // http://www.ietf.org/rfc/rfc3986.txt
    return (__bridge_transfer NSString *)
    CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (__bridge CFStringRef)self,
                                            NULL,
                                            (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8);
}

- (NSString *)URLDecodedString {
    
    return [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}



@end
