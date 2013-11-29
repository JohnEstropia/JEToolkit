//
//  JECompilerDefines.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#ifndef JEToolkit_JECompilerDefines_h
#define JEToolkit_JECompilerDefines_h

#import <Foundation/Foundation.h>


#pragma mark - Function attributes

#define JE_CONST                    __attribute__((const))
#define JE_EXTERN                   extern
#define JE_EXTERN_INLINE            extern inline
#define JE_FORMAT_STRING(F,A)       NS_FORMAT_FUNCTION(F,A)
#define JE_INLINE                   static inline
#define JE_NONNULL_ALL              __attribute__((nonnull))
#define JE_NONNULL(...)             __attribute__((nonnull(__VA_ARGS__)))
#define JE_OVERLOAD                 __attribute__((overloadable))
#define JE_STATIC                   static
#define JE_STATIC_INLINE            FOUNDATION_STATIC_INLINE
#define JE_REQUIRES_NIL_TERMINATION NS_REQUIRES_NIL_TERMINATION
#define JE_FILE_NAME                ((strrchr(__FILE__, '/') ?: (__FILE__ - 1)) + 1)


#endif
