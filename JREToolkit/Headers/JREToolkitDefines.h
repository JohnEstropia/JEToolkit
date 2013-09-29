//
//  JREToolkitDefines.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#ifndef JREToolkit_JREToolkitDefines_h
#define JREToolkit_JREToolkitDefines_h

#pragma mark - Function attributes

#define JRE_CONST               __attribute__((const))
#define JRE_EXTERN              extern
#define JRE_EXTERN_INLINE       extern inline
#define JRE_FORMAT_STRING(F,A)  __attribute__((format(__NSString__, F, A)))
#define JRE_INLINE              static inline
#define JRE_NONNULL_ALL         __attribute__((nonnull))
#define JRE_NONNULL(...)        __attribute__((nonnull(__VA_ARGS__)))
#define JRE_OVERLOAD            __attribute__((overloadable))
#define JRE_STATIC              static
#define JRE_STATIC_INLINE       static inline


#endif
