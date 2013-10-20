//
//  JREDebugging.h
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JREToolkitDefines.h"


#if DEBUG

/*! Dumps any variable, expression, etc. to the console. Also displays the source filename, line number, and method name.
 */
#define JREDump(...)        do { \
                                const char *objCType = @encode(typeof(__VA_ARGS__)); \
                                const void *(^pointerize)(const void *) = ^const void *(const void *_valueOrObject){ \
                                    return (objCType[0] == '[' ? (*(void **)_valueOrObject) : _valueOrObject); \
                                }; \
                                _Pragma("clang diagnostic push") \
                                _Pragma("clang diagnostic ignored \"-Wmissing-braces\"") \
                                _Pragma("clang diagnostic ignored \"-Wint-conversion\"") \
                                _JRELogObject(__FILE__, __LINE__, __PRETTY_FUNCTION__, #__VA_ARGS__, pointerize((typeof(__VA_ARGS__)[]){(__VA_ARGS__)}), objCType); \
                                _Pragma("clang diagnostic pop") \
                            } while(0)

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define JRELog(format, ...) _JRELogFormat(__FILE__, __LINE__, __PRETTY_FUNCTION__, format, __VA_ARGS__)


#else

#define JREDump(...)                do {} while(0)
#define JRELog(format, ...)         do {} while(0)

#endif


JRE_EXTERN
void _JRELogObject(const char *filePath,
                   int line,
                   const char *functionName,
                   const char *objectName,
                   const void *value,
                   const char *objCType);

JRE_EXTERN_INLINE JRE_FORMAT_STRING(4,5)
void _JRELogFormat(const char *filePath,
                   int line,
                   const char *functionName,
                   NSString *format,
                   ...);