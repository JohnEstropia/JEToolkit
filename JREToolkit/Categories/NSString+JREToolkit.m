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

#pragma mark Paths

+ (NSString *)pathToDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)pathToTemporaryDirectory
{
    return NSTemporaryDirectory();
}

+ (NSString *)pathToCachesDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)pathToAppSupportDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark String Manipulation

- (NSString *)trimmedString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark Validation

+ (NSString *)stringFromValue:(id)value
{
    if (value)
    {
        if ([value isKindOfClass:[NSString class]])
        {
            return value;
        }
        if ([value isKindOfClass:[NSNumber class]])
        {
            return [(NSNumber *)value stringValue];
        }
        if ([value isKindOfClass:[NSData class]])
        {
            return [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

- (BOOL)isEmpty
{
    return ([[self trimmedString] length] <= 0);
}

@end
