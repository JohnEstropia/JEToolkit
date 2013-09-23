//
//  NSCache+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCache (JREToolkit)

/*! Allows key subscripting with NSCache. Equivalent to -[NSCache objectForKey:]
 */
- (id)objectForKeyedSubscript:(id)key;

/*! Allows key subscripting with NSCache. Equivalent to -[NSCache setObject:forKey:]
 */
- (void)setObject:(id)obj forKeyedSubscript:(id)key;

@end
