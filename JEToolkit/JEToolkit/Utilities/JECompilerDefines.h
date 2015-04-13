//
//  JECompilerDefines.h
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
#define JE_PRECISE_LIFETIME         __attribute__((objc_precise_lifetime))
#define JE_STATIC                   static
#define JE_STATIC_INLINE            static inline
#define JE_REQUIRES_NIL_TERMINATION NS_REQUIRES_NIL_TERMINATION
#define JE_REQUIRES_SUPER           NS_REQUIRES_SUPER
#define JE_WARN_UNUSED_RESULT       DISPATCH_WARN_RESULT


#pragma mark - Swift support

#define JE_DESIGNATED_INITIALIZER   NS_DESIGNATED_INITIALIZER




#pragma mark - Constants

#define __JE_FILE_NAME__            ((strrchr(__FILE__, '/') ?: (__FILE__ - 1)) + 1)



#pragma mark - Pragma helpers


#define _JE_PRAGMA_STRINGIZE(x)     #x
#define JE_PRAGMA_PUSH               _Pragma("clang diagnostic push")
#define JE_PRAGMA_IGNORE(linkerFlag) _Pragma(_JE_PRAGMA_STRINGIZE(clang diagnostic ignored linkerFlag))
#define JE_PRAGMA_ERROR(linkerFlag)  _Pragma(_JE_PRAGMA_STRINGIZE(clang diagnostic error linkerFlag))
#define JE_PRAGMA_POP                _Pragma("clang diagnostic pop")



#endif
