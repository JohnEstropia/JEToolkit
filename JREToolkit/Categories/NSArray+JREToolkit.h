//
//  NSArray+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (JREToolkit)

#pragma mark - Container Tools

/*! Returns the first object if it exists, or nil otherwise
 */
- (id)firstObject;

/*! Returns a new array with shuffled objects from the receiver
 */
- (NSArray *)shuffledArray;


#pragma mark - Parser Outputs

+ (NSArray *)rowsFromTSVFile:(NSString *)path
                       error:(NSError * __autoreleasing *)error;


@end
