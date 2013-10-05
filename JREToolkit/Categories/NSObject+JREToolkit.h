//
//  NSObject+JREToolkit.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JREToolkit)

/*! Convenience method for NSStringFromClass(self)
 */
+ (NSString *)className;

/*! Returns the iPhone or iPad-specific subclass for the receiver
 */
+ (Class)classForIdiom;

/*! Allocates an instance of the iPhone or iPad-specific subclass for the receiver
 */
+ (instancetype)allocForIdiom;


@end
