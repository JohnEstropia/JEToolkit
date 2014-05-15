//
//  JECompilerDefines.h
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#ifndef JEToolkit_JECompilerDefines_h
#define JEToolkit_JECompilerDefines_h

#import <Foundation/NSObjCRuntime.h>


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
#define JE_STATIC_INLINE            static inline
#define JE_REQUIRES_NIL_TERMINATION NS_REQUIRES_NIL_TERMINATION
#define JE_WARN_UNUSED_RESULT       DISPATCH_WARN_RESULT



#pragma mark - Constants

#define __JE_FILE_NAME__            ((strrchr(__FILE__, '/') ?: (__FILE__ - 1)) + 1)



#pragma mark - Pragma helpers


#define _JE_PRAGMA_STRINGIZE(x)     #x
#define JE_PRAGMA_PUSH               _Pragma("clang diagnostic push")
#define JE_PRAGMA_IGNORE(linkerFlag) _Pragma(_JE_PRAGMA_STRINGIZE(clang diagnostic ignored linkerFlag))
#define JE_PRAGMA_ERROR(linkerFlag)  _Pragma(_JE_PRAGMA_STRINGIZE(clang diagnostic error linkerFlag))
#define JE_PRAGMA_POP                _Pragma("clang diagnostic pop")



#endif
