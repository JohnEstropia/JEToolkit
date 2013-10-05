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

/*! Dumps any variable, expression, etc. to the console. Also displays the source filename, line number, and method name. For static arrays, use JREDumpArray() instead.
 */
#define JREDump(valueOrObject)      do { \
                                        typeof(valueOrObject) _valueOrObject = (valueOrObject); \
                                        _JRELogObject(__FILE__, __LINE__, __PRETTY_FUNCTION__, #valueOrObject, &_valueOrObject, @encode(typeof(valueOrObject)), 0); \
                                    } while(0)

/*! Dumps static arrays to the console. Also displays the source filename, line number, and method name. For all other variables, expressions, etc. ise JREDump() instead.
 */
#define JREDumpArray(staticArray)   do { \
                                        _JRELogObject(__FILE__, __LINE__, __PRETTY_FUNCTION__, #staticArray, &staticArray, @encode(typeof(staticArray)), sizeof(typeof(staticArray[0]))); \
                                    } while(0)

/*! Logs a format string to the console. Also displays the source filename, line number, and method name.
 */
#define JRELog(format, ...)         _JRELogFormat(__FILE__, __LINE__, __PRETTY_FUNCTION__, format, __VA_ARGS__)



JRE_EXTERN
void _JRELogObject(const char *filePath,
                   int line,
                   const char *functionName,
                   const char *objectName,
                   const void *value,
                   const char *objCType,
                   size_t sizePerElement);

JRE_EXTERN_INLINE JRE_FORMAT_STRING(4,5)
void _JRELogFormat(const char *filePath,
                   int line,
                   const char *functionName,
                   NSString *format,
                   ...);

#else

#define JREDump(valueOrObject)      do {} while(0)
#define JREDumpArray(staticArray)   do {} while(0)
#define JRELog(format, ...)         do {} while(0)

#endif