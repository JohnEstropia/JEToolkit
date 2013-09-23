//
//  NSString+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/06/16.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSString+JREToolkit.h"

@implementation NSString (JREToolkit)

#pragma mark - public

#pragma mark Localization

- (NSString *)L8N
{
	NSString *string = NSLocalizedString(self, nil);
    NSCAssert(![self isEqualToString:string], @"\"%@\" not found in Localizable.strings", self);
    return string;
}

- (NSString *)L8NInStringsFile:(NSString *)stringsFile
{
	NSString *string = (stringsFile
                        ? NSLocalizedStringFromTable(self, stringsFile, nil)
                        : NSLocalizedString(self, nil));
    NSCAssert(![self isEqualToString:string],
              @"\"%@\" not found in %@.strings",
              self,
              (stringsFile ?: @"Localizable"));
    return string;
}

#pragma mark Paths

+ (NSString *)documentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)temporaryDirectory
{
    return NSTemporaryDirectory();
}

+ (NSString *)cachesDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)appSupportDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark String Manipulation

- (NSString *)trimmedString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark Validation

+ (BOOL)isNilOrEmptyString:(id)valueOrNil
{
    return (![valueOrNil isKindOfClass:self]
            || [[(NSString *)valueOrNil trimmedString] length] <= 0);
}

+ (NSString *)nonEmptyStringOrNil:(id)valueOrNil
{
    if (![valueOrNil isKindOfClass:self])
    {
        return nil;
    }
    
    NSString *trimmedString = [(NSString *)valueOrNil trimmedString];
    return ([trimmedString length] > 0 ? trimmedString : nil);
}

#pragma mark Conversion

+ (NSString *)stringFromValue:(id)valueOrNil
{
    if (valueOrNil)
    {
        if ([valueOrNil isKindOfClass:self])
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



@end
