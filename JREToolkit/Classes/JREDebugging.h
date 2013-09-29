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

#define JREDump(val) ({ typeof(val) _dumpVal = (val); _JREDump(__FILE__, __LINE__, __PRETTY_FUNCTION__, #val, &_dumpVal, @encode(typeof(val)), 0); })
#define JREDumpArray(val) ({ _JREDump(__FILE__, __LINE__, __PRETTY_FUNCTION__, #val, &val, @encode(typeof(val)), sizeof(typeof(val[0]))); })

#define JRELog(format, ...) _JRELog(__FILE__, __LINE__, __PRETTY_FUNCTION__, format, __VA_ARGS__)


JRE_EXTERN
void _JREDump(const char *filePath, int line, const char *functionName, const char *objectName, const void *value, const char *objCType, size_t sizePerElement);

JRE_EXTERN_INLINE JRE_FORMAT_STRING(4,5)
void _JRELog(const char *filePath, int line, const char *functionName, NSString *format, ...);


#else // NDEBUG

#define JRELog(obj)
#define JRELog(obj)

#endif
