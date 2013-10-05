//
//  NSIndexSet+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexSet (JREToolkit)

/*! Returns the nth integer stored at the receiver
 */
- (NSUInteger)integerAtIndex:(NSInteger)index;

/*! Returns the position of an integer in the receiver
 */
- (NSInteger)indexOfInteger:(NSUInteger)integer;

@end
