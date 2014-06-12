//
//  NSObject+JEDebugging.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/10/05.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JEDebugging)

#pragma mark - Logging

/*! Returns a string with detailed information about the receiver.
 Subclasses should override this method directly or with categories.
 */
- (NSString *)loggingDescription;

/*! Returns a string with detailed information about the receiver, with options to include the class name and/or the object memory address.
 Because this calls @p loggingDescription internally, subclasses typically don't need to override this method.
 */
- (NSString *)loggingDescriptionIncludeClass:(BOOL)includeClass
                              includeAddress:(BOOL)includeAddress;

@end
