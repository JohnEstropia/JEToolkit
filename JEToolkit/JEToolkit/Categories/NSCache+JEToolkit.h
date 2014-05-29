//
//  NSCache+JEToolkit.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/15.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JECompilerDefines.h"


@interface NSCache (JEToolkit)

/*! Allows key subscripting with NSCache. Equivalent to -[NSCache objectForKey:]
 */
- (id)objectForKeyedSubscript:(id)key JE_NONNULL_ALL;

/*! Allows key subscripting with NSCache. Equivalent to -[NSCache setObject:forKey:]
 */
- (void)setObject:(id)obj forKeyedSubscript:(id)key JE_NONNULL_ALL;


@end
