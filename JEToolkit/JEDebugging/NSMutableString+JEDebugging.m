//
//  NSMutableString+JEDebugging.m
//  JEToolkit
//
//  Created by DIT John Estropia on 2013/11/26.
//  Copyright (c) 2013年 John Rommel Estropia. All rights reserved.
//

#import "NSMutableString+JEDebugging.h"

#import "NSString+JEToolkit.h"


@implementation NSMutableString (JEDebugging)

#pragma mark - public

+ (NSDictionary *)CStringBackslashEscapeMapping
{
    static NSDictionary *replacementMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // http://en.wikipedia.org/wiki/ASCII
        replacementMapping = @{ @"\0" : @"\\0",
                                @"\a" : @"\\a",
                                @"\b" : @"\\b",
                                @"\t" : @"\\t",
                                @"\n" : @"\\n",
                                @"\v" : @"\\v",
                                @"\f" : @"\\f",
                                @"\r" : @"\\r",
                                @"\e" : @"\\e",
                                @"\"" : @"\\\"" };
        
    });
    return replacementMapping;
}

- (void)replaceWithCStringRepresentation
{
    [self
     replaceOccurrencesOfString:@"\\"
     withString:@"\\\\"
     options:(NSCaseInsensitiveSearch | NSLiteralSearch)
     range:[self range]];
    
    [[[self class] CStringBackslashEscapeMapping] enumerateKeysAndObjectsUsingBlock:^(NSString *occurrence, NSString *replacement, BOOL *stop) {
        
        [self
         replaceOccurrencesOfString:occurrence
         withString:replacement
         options:(NSCaseInsensitiveSearch | NSLiteralSearch)
         range:[self range]];
        
    }];
    
    [self insertString:@"\"" atIndex:0];
    [self appendString:@"\""];
}

- (void)indentByLevel:(NSUInteger)indentLevel
{
    static NSMutableArray *indentStrings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        indentStrings = [[NSMutableArray alloc] init];
        
    });
    
    NSUInteger indentStringsCount = [indentStrings count];
    if (indentLevel >= indentStringsCount)
    {
        for (NSInteger indentLevelToAdd = indentStringsCount; indentLevelToAdd <= indentLevel; ++indentLevelToAdd)
        {
            [indentStrings addObject:[@"\n"
                                      stringByPaddingToLength:((indentLevelToAdd * 3) + 1)
                                      withString:@" "
                                      startingAtIndex:0]];
        }
    }
    
    [self
     replaceOccurrencesOfString:@"\n"
     withString:indentStrings[indentLevel]
     options:(NSCaseInsensitiveSearch | NSLiteralSearch)
     range:[self range]];
}


@end
