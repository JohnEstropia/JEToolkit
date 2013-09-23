//
//  NSArray+JREToolkit.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "NSArray+JREToolkit.h"

#import "NSMutableArray+JREToolkit.h"


@implementation NSArray (JREToolkit)

#pragma mark - public

#pragma mark Container Tools

- (id)firstObject
{
    return ([self count] > 0 ? self[0] : nil);
}

- (NSArray *)shuffledArray
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array shuffle];
    return array;
}

#pragma mark Parser Outputs

+ (NSArray *)rowsFromTSVFile:(NSString *)path
                       error:(NSError * __autoreleasing *)error
{
    NSMutableArray *rows;
    
    @autoreleasepool {
        
        NSStringEncoding encoding = kNilOptions;
        NSError *fileError;
        NSString *originalString = [[NSString alloc] initWithContentsOfFile:path
                                                               usedEncoding:&encoding
                                                                      error:&fileError];
        if (!originalString)
        {
            if (error)
            {
                (*error) = fileError;
            }
            return nil;
        }
        
        rows = [[NSMutableArray alloc] init];
        [originalString enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            
            [rows addObject:[line componentsSeparatedByString:@"\t"]];
            
        }];
        
    }
    
    return rows;
}


@end
