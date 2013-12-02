//
//  NSMutableString+JEDebugging.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/11/26.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableString (JEDebugging)

/*! Converts the receiver to how it would be backslash-escaped in a C source code and encloses it in double quotes.
 */
- (void)escapeWithUTF8CStringRepresentation;

/*! Indents the receiver by two spaces for each indentLevel. The first line will not be indented.
 */
- (void)indentByLevel:(NSUInteger)indentLevel;

@end