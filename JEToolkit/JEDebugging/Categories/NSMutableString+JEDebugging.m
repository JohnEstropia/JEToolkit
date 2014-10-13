//
//  NSMutableString+JEDebugging.m
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

#import "NSMutableString+JEDebugging.h"

#import "NSString+JEToolkit.h"


@implementation NSMutableString (JEDebugging)

#pragma mark - Public

- (void)escapeWithUTF8CStringRepresentation
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
    
    [self
     replaceOccurrencesOfString:@"\\"
     withString:@"\\\\"
     options:(NSCaseInsensitiveSearch | NSLiteralSearch)
     range:[self range]];
    
    [replacementMapping enumerateKeysAndObjectsUsingBlock:^(NSString *occurrence, NSString *replacement, BOOL *stop) {
        
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
