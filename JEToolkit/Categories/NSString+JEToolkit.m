//
//  NSString+JEToolkit.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/06/16.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSString+JEToolkit.h"

@implementation NSString (JEToolkit)

#pragma mark - public

#pragma mark Paths

+ (NSString *)documentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)temporaryDirectory
{
    return NSTemporaryDirectory();
}

+ (NSString *)cachesDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)appSupportDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) firstObject];
}

#pragma mark String Manipulation

- (NSString *)trimmedString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray *)charactersArray
{
	NSInteger length = [self length];
	NSMutableArray *characters = [[NSMutableArray alloc] initWithCapacity:length];
    [self
     enumerateSubstringsInRange:NSMakeRange(0, length)
     options:NSStringEnumerationByComposedCharacterSequences
     usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         [characters addObject:substring];
         
     }];
	return characters;
}

#pragma mark Validation

+ (BOOL)isNilOrEmptyString:(id)valueOrNil
{
    return (![valueOrNil isKindOfClass:[NSString class]]
            || [[(NSString *)valueOrNil trimmedString] length] <= 0);
}

+ (NSString *)nonEmptyStringOrNil:(id)valueOrNil
{
    if (![valueOrNil isKindOfClass:[NSString class]])
    {
        return nil;
    }
    
    NSString *trimmedString = [(NSString *)valueOrNil trimmedString];
    return ([trimmedString length] > 0 ? trimmedString : nil);
}

- (BOOL)containsSubstring:(NSString *)substring
{
    NSCParameterAssert([substring isKindOfClass:[NSString class]]);
    
    return [self containsSubstring:substring options:NSLiteralSearch];
}

- (BOOL)containsSubstring:(NSString *)substring
                  options:(NSStringCompareOptions)options
{
    NSCParameterAssert([substring isKindOfClass:[NSString class]]);
    
    return ([self rangeOfString:substring options:options].location != NSNotFound);
}

#pragma mark Conversion

+ (NSString *)stringFromValue:(id)valueOrNil
{
    if (valueOrNil)
    {
        if ([valueOrNil isKindOfClass:[NSString class]])
        {
            return valueOrNil;
        }
        if ([valueOrNil isKindOfClass:[NSNumber class]])
        {
            return [(NSNumber *)valueOrNil stringValue];
        }
        if ([valueOrNil isKindOfClass:[NSData class]])
        {
            return [[self alloc] initWithData:valueOrNil encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

+ (NSString *)stringFromFileSize:(int64_t)fileSize
{
	if (fileSize < 1023)
    {
		return [NSString stringWithFormat:@"%llu bytes", fileSize];
    }
    
	double decimalSize = ((double)fileSize / 1024.0);
	if (decimalSize < 1023.0)
    {
		return [NSString stringWithFormat:@"%1.1f KB", decimalSize];
    }
    
	decimalSize /= 1024.0;
	if (decimalSize < 1023.0)
    {
		return [NSString stringWithFormat:@"%1.1f MB", decimalSize];
    }
    
	decimalSize /= 1024.0;
    return [NSString stringWithFormat:@"%1.1f GB", decimalSize];
}

- (NSString *)canonicalString
{
    return [[self trimmedString] lowercaseString];
}



@end
