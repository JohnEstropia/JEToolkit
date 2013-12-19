//
//  _JEAssociatedObjectsWeakWrapper.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/12/14.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _JEAssociatedObjectsWeakWrapper : NSObject

@property (nonatomic, weak, readonly) id weakObject;

- (id)initWithWeakObject:(id)weakObject;

@end
