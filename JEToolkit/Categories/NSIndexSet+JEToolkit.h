//
//  NSIndexSet+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (JEToolkit)

/*! Returns the nth integer stored at the receiver. Raises NSRangeException if index is out of the receiver's bounds.
 */
- (NSUInteger)integerAtIndex:(NSInteger)index;

/*! Returns the position of an integer in the receiver, or NSNotFound if the integer is not found.
 */
- (NSInteger)indexOfInteger:(NSUInteger)integer;

@end
