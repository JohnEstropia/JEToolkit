//
//  JREDebugging.m
//  JREToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JREDebugging.h"


#pragma mark - private

JRE_STATIC
NSString *_JREGetStringFromObjCType(const char *objCType,
                                    const void *value,
                                    const NSUInteger indentLevel,
                                    NSString *__autoreleasing *valueString,
                                    size_t *sizeOfType)
{
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    
    char typePrefix = objCType[0];
    while (typePrefix != '\0'
           && (typePrefix == 'r'
               || typePrefix == 'n'
               || typePrefix == 'N'
               || typePrefix == 'o'
               || typePrefix == 'O'
               || typePrefix == 'R'
               || typePrefix == 'V'))
    {
        objCType++;
        
        if (!objCType)
        {
            return @"";
        }
        
        typePrefix = objCType[0];
    }
    
    objCType++;
    switch (typePrefix)
    {
        case 'c':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"'%1$c' (%1$i)", (* (char *)value)];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(char);
            }
            return @"char";
        }
        case 'i':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (int *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(int);
            }
            return @"int";
        }
        case 's':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (short *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(short);
            }
            return @"short";
        }
        case 'l':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (long *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(long);
            }
            return @"long";
        }
        case 'q':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (long long *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(long long);
            }
            return @"long long";
        }
        case 'C':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (unsigned char *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(unsigned char);
            }
            return @"unsigned char";
        }
        case 'I':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (unsigned int *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(unsigned int);
            }
            return @"unsigned int";
        }
        case 'S':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (unsigned short *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(unsigned short);
            }
            return @"unsigned short";
        }
        case 'L':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (unsigned long *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(unsigned long);
            }
            return @"unsigned long";
        }
        case 'Q':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (unsigned long long *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(unsigned long long);
            }
            return @"unsigned long long";
        }
        case 'f':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (float *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(float);
            }
            return @"float";
        }
        case 'd':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (double *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(double);
            }
            return @"double";
        }
        case 'B':
        {
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:@"%@", @((* (bool *)value))];
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(bool);
            }
            return @"bool";
        }
        case '*':
        {
            if (valueString)
            {
                const char *dereferencedValue = (* (char **)value);
                (* valueString) = (dereferencedValue
                                   ? [NSString stringWithFormat:@"<%p> %s", dereferencedValue, dereferencedValue]
                                   : @"NULL");
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(char *);
            }
            return @"char *";
        }
        case '@':
        {
            const id dereferencedValue = (id)(* (__unsafe_unretained id *)value);
            if (valueString)
            {
                (* valueString) = (dereferencedValue
                                   ? [NSString stringWithFormat:@"%@", dereferencedValue]
                                   : @"nil");
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(id);
            }
            return (dereferencedValue
                    ? [NSString stringWithFormat:@"%@ *", [dereferencedValue class]]
                    : @"id");
        }
        case '#':
        {
            if (valueString)
            {
                const Class dereferencedValue = (* (Class *)value);
                (* valueString) = (NSStringFromClass(dereferencedValue) ?: @"Nil");
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(Class);
            }
            return @"Class";
        }
        case ':':
        {
            if (valueString)
            {
                const SEL dereferencedValue = (* (SEL *)value);
                (* valueString) = (NSStringFromSelector(dereferencedValue) ?: @"NULL");
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(SEL);
            }
            return @"SEL";
        }
        case 'v':
        {
            if (valueString)
            {
                (* valueString) = @"";
            }
            if (sizeOfType)
            {
                (* sizeOfType) = sizeof(void);
            }
            return @"void";
        }
        case 'b':
        {
            NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:objCType]];
            
            unsigned long long bitCount = 0;
            [scanner scanUnsignedLongLong:&bitCount];
            
            if (valueString)
            {
                (* valueString) = @"";
            }
            if (sizeOfType)
            {
                (* sizeOfType) = 0;
            }
            return [NSString stringWithFormat:@"bit:%llu", bitCount];
        }
        case '{':
        {
            NSMutableString *substring = [[NSMutableString alloc] initWithFormat:@"%s", objCType];
            [substring deleteCharactersInRange:NSMakeRange(([substring length] - 1), 1)];
            NSScanner *scanner = [[NSScanner alloc] initWithString:substring];
            
            NSString *structName;
            [scanner scanUpToString:@"=" intoString:&structName];
            
            NSString *subtype;
            [scanner scanUpToString:@"\0" intoString:&subtype];
            
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:
                                   @"%@",
                                   [[NSValue alloc] initWithBytes:value objCType:objCType]];
            }
            if (sizeOfType)
            {
#warning TODO: wrong size
                (* sizeOfType) = sizeof(void);
            }
            return [NSString stringWithFormat:@"struct %@", structName];
        }
        case '(':
        {
            NSMutableString *substring = [[NSMutableString alloc] initWithFormat:@"%s", objCType];
            [substring deleteCharactersInRange:NSMakeRange(([substring length] - 1), 1)];
            NSScanner *scanner = [[NSScanner alloc] initWithString:substring];
            
            NSString *structName;
            [scanner scanUpToString:@"=" intoString:&structName];
            
            NSString *subtype;
            [scanner scanUpToString:@"\0" intoString:&subtype];
            
            if (valueString)
            {
                (* valueString) = [NSString stringWithFormat:
                                   @"%@",
                                   [[NSValue alloc] initWithBytes:value objCType:objCType]];
            }
            if (sizeOfType)
            {
#warning TODO: wrong size
                (* sizeOfType) = sizeof(void);
            }
            return [NSString stringWithFormat:@"union %@", structName];
        }
        case '^':
        {
            NSScanner *scanner = [[NSScanner alloc] initWithString:
                                  [[NSString alloc] initWithFormat:@"%s", objCType]];
            NSString *subtype;
            [scanner scanUpToString:@"\0" intoString:&subtype];
            
            const void *dereferencedValue = (* (void **)value);
            if (valueString)
            {
                (* valueString) = (dereferencedValue
                                   ? [NSString stringWithFormat:@"<%p>", dereferencedValue]
                                   : @"NULL");
            }
            if (sizeOfType)
            {
#warning TODO: wrong size
                (* sizeOfType) = sizeof(void);
            }
            
            return [NSString stringWithFormat:
                    @"%@ *",
                    _JREGetStringFromObjCType([subtype UTF8String],
                                              dereferencedValue,
                                              (indentLevel + 1),
                                              NULL,
                                              NULL)];
        }
        case '[':
        {
            NSMutableString *substring = [[NSMutableString alloc] initWithFormat:@"%s", objCType];
            [substring deleteCharactersInRange:NSMakeRange(([substring length] - 1), 1)];
            NSScanner *scanner = [[NSScanner alloc] initWithString:substring];
            
            unsigned long long length = 0;
            [scanner scanUnsignedLongLong:&length];
            
            NSString *subtype;
            [scanner scanUpToString:@"\0" intoString:&subtype];
            
            NSMutableString *arrayString = [[NSMutableString alloc] init];
            for (unsigned long long i = 0; i < length; ++i)
            {
                if (i == 0)
                {
                    [arrayString appendString:@"\n"];
                    
                    for (NSUInteger indent = 0; indent <= indentLevel; ++indent)
                    {
                        [arrayString appendString:@"\t"];
                    }
                }
                
                NSString *itemString;
                [arrayString appendFormat:@"\t[%llu]: (%@) ", i,
                 _JREGetStringFromObjCType([subtype UTF8String],
                                           ((Byte *)value + (i * 1)),
                                           (indentLevel + 1),
                                           &itemString,
                                           NULL)];
                [arrayString appendFormat:@"%@,\n", itemString];
                
                for (NSUInteger indent = 0; indent <= indentLevel; ++indent)
                {
                    [arrayString appendString:@"\t"];
                }
            }
            
            const void *dereferencedValue = (* (void **)value);
            (* valueString) = [NSString stringWithFormat:
                               @"%@ [%@]",
                               (dereferencedValue
                                ? [[NSString alloc] initWithFormat:@"<%p>", dereferencedValue]
                                : @"NULL"),
                               arrayString];
            
            return [NSString stringWithFormat:
                    @"%@[%llu]",
                    _JREGetStringFromObjCType([subtype UTF8String],
                                              dereferencedValue,
                                              (indentLevel + 1),
                                              NULL,
                                              NULL),
                    length];
        }
        case '?': return @"func";
        default: return @"";
    }
}


#pragma mark - public

void _JREDump(const char *filePath,
              int line,
              const char *functionName,
              const char *objectName,
              const void *value,
              const char *objCType,
              size_t sizePerElement)
{
//    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
//    
//    char typePrefix = objCType[0];
//    while (typePrefix != '\0'
//           && (typePrefix == 'r'
//               || typePrefix == 'n'
//               || typePrefix == 'N'
//               || typePrefix == 'o'
//               || typePrefix == 'O'
//               || typePrefix == 'R'
//               || typePrefix == 'V'))
//    {
//        objCType++;
//        
//        if (!objCType)
//        {
//            return;
//        }
//        
//        typePrefix = objCType[0];
//    }
//    
//    NSString *typeName;
//    id object;
//    
//    switch (*objCType)
//    {
//        case 'c':
//            object = [[NSNumber alloc] initWithChar:(* (char *)value)];
//            typeName = @"char";
//            break;
//        case 'i':
//            object = [[NSNumber alloc] initWithInt:(* (int *)value)];
//            typeName = @"int";
//            break;
//        case 's':
//            object = [[NSNumber alloc] initWithShort:(* (short *)value)];
//            typeName = @"short";
//            break;
//        case 'l':
//            object = [[NSNumber alloc] initWithLong:(* (long *)value)];
//            typeName = @"long";
//            break;
//        case 'q':
//            object = [[NSNumber alloc] initWithLongLong:(* (long long *)value)];
//            typeName = @"long long";
//            break;
//        case 'C':
//            object = [[NSNumber alloc] initWithUnsignedChar:(* (unsigned char *)value)];
//            typeName = @"unsigned char";
//            break;
//        case 'I':
//            object = [[NSNumber alloc] initWithUnsignedInt:(* (unsigned int *)value)];
//            typeName = @"unsigned int";
//            break;
//        case 'S':
//            object = [[NSNumber alloc] initWithUnsignedShort:(* (unsigned short *)value)];
//            typeName = @"unsigned short";
//            break;
//        case 'L':
//            object = [[NSNumber alloc] initWithUnsignedLong:(* (unsigned long *)value)];
//            typeName = @"unsigned long";
//            break;
//        case 'Q':
//            object = [[NSNumber alloc] initWithUnsignedLongLong:(* (unsigned long long *)value)];
//            typeName = @"unsigned long long";
//            break;
//        case 'f':
//            object = [[NSNumber alloc] initWithFloat:(* (float *)value)];
//            typeName = @"float";
//            break;
//        case 'd':
//            object = [[NSNumber alloc] initWithDouble:(* (double *)value)];
//            typeName = @"double";
//            break;
//        case 'B':
//            object = [[NSNumber alloc] initWithBool:(* (bool *)value)];
//            typeName = @"bool";
//            break;
//        case '*':
//        {
//            const char *dereferencedValue = (* (char **)value);
//            object = (dereferencedValue
//                      ? [[NSString alloc] initWithFormat:@"<%p> %s", dereferencedValue, dereferencedValue]
//                      : @"NULL");
//            typeName = @"char *";
//        }
//            break;
//        case '@':
//        {
//            const id dereferencedValue = (id)(* (__unsafe_unretained id *)value);
//            object = (dereferencedValue ?: @"nil");
//            typeName = (dereferencedValue
//                        ? [[NSString alloc] initWithFormat:@"%@ *", [dereferencedValue class]]
//                        : @"id");
//        }
//            break;
//        case '#':
//        {
//            const Class dereferencedValue = (* (Class *)value);
//            object = ((dereferencedValue
//                       ? NSStringFromClass(dereferencedValue) : nil)
//                      ?: @"Nil");
//            typeName = @"Class";
//        }
//            break;
//        case ':':
//        {
//            const SEL dereferencedValue = (* (SEL *)value);
//            object = ((dereferencedValue
//                       ? NSStringFromSelector(dereferencedValue) : nil)
//                      ?: @"NULL");
//            typeName = @"SEL";
//        }
//            break;
//        case 'v':
//            object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//            typeName = @"void";
//            break;
//        case '{':
//        {
//            NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:objCType]];
//            [scanner scanString:@"{" intoString:NULL];
//            
//            NSString *structName;
//            [scanner scanUpToString:@"=" intoString:&structName];
//            
//            object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//            typeName = [[NSString alloc] initWithFormat:@"struct %@", structName];
//        }
//            break;
//        case '(':
//        {
//            NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:objCType]];
//            [scanner scanString:@"(" intoString:NULL];
//            
//            NSString *structName;
//            [scanner scanUpToString:@"=" intoString:&structName];
//            
//            object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//            typeName = [[NSString alloc] initWithFormat:@"union %@", structName];
//        }
//            break;
//        case 'b':
//        {
//            NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:objCType]];
//            [scanner scanString:@"b" intoString:NULL];
//            
//            unsigned long long bitCount = 0;
//            [scanner scanUnsignedLongLong:&bitCount];
//            
//            object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//            typeName = [[NSString alloc] initWithFormat:@"bit:%llu", bitCount];
//        }
//            break;
//        case '[':
//        {
//            NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:objCType]];
//            [scanner scanString:@"[" intoString:NULL];
//            
//            unsigned long long length = 0;
//            [scanner scanUnsignedLongLong:&length];
//            
//            NSString *subtype;
//            [scanner scanUpToString:@"]" intoString:&subtype];
//            
//            switch ([subtype characterAtIndex:0])
//            {
//                case 'c':
//                    object = [[NSString alloc] initWithBytes:value length:length encoding:NSUTF8StringEncoding];
//                    typeName = [[NSString alloc] initWithFormat:@"char[%llu]", length];
//                    break;
//                case 'i':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"int[%llu]", length];
//                    break;
//                case 's':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"short[%llu]", length];
//                    break;
//                case 'l':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"long[%llu]", length];
//                    break;
//                case 'q':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"long long[%llu]", length];
//                    break;
//                case 'C':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"unsigned char[%llu]", length];
//                    break;
//                case 'I':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"unsigned int[%llu]", length];
//                    break;
//                case 'S':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"unsigned short[%llu]", length];
//                    break;
//                case 'L':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"unsigned long[%llu]", length];
//                    break;
//                case 'Q':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"unsigned long long[%llu]", length];
//                    break;
//                case 'f':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"float[%llu]", length];
//                    break;
//                case 'd':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"double[%llu]", length];
//                    break;
//                case 'B':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"bool[%llu]", length];
//                    break;
//                case '*':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"char *[%llu]", length];
//                    break;
//                case '@':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"id[%llu]", length];
//                    break;
//                case '#':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"Class[%llu]", length];
//                    break;
//                case ':':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"SEL[%llu]", length];
//                    break;
//                case '[':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"[][%llu]", length];
//                    break;
//                case 'v':
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"void[%llu]", length];
//                    break;
//                case '{':
//                {
//                    NSScanner *scanner = [[NSScanner alloc] initWithString:subtype];
//                    [scanner scanString:@"{" intoString:NULL];
//                    
//                    NSString *structName;
//                    [scanner scanUpToString:@"=" intoString:&structName];
//                    
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"struct %@[%llu]", structName, length];
//                }
//                    break;
//                case '(':
//                {
//                    NSScanner *scanner = [[NSScanner alloc] initWithString:subtype];
//                    [scanner scanString:@"(" intoString:NULL];
//                    
//                    NSString *structName;
//                    [scanner scanUpToString:@"=" intoString:&structName];
//                    
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"union %@[%llu]", structName, length];
//                }
//                    break;
//                case 'b':
//                {
//                    NSScanner *scanner = [[NSScanner alloc] initWithString:subtype];
//                    [scanner scanString:@"b" intoString:NULL];
//                    
//                    unsigned long long bitCount = 0;
//                    [scanner scanUnsignedLongLong:&bitCount];
//                    
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"bit:%llu[%llu]", bitCount, length];
//                }
//                    break;
//                case '^':
//                {
//                    NSScanner *scanner = [[NSScanner alloc] initWithString:subtype];
//                    [scanner scanString:@"^" intoString:NULL];
//                    
//                    NSString *subsubtype;
//                    [scanner scanUpToString:@"]" intoString:&subsubtype];
//                    
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    switch ([subsubtype characterAtIndex:0])
//                    {
//                        case 'c':
//                            typeName = [[NSString alloc] initWithFormat:@"char *[%llu]", length];
//                            break;
//                        case 'i':
//                            typeName = [[NSString alloc] initWithFormat:@"int *[%llu]", length];
//                            break;
//                        case 's':
//                            typeName = [[NSString alloc] initWithFormat:@"short *[%llu]", length];
//                            break;
//                        case 'l':
//                            typeName = [[NSString alloc] initWithFormat:@"long *[%llu]", length];
//                            break;
//                        case 'q':
//                            typeName = [[NSString alloc] initWithFormat:@"long long *[%llu]", length];
//                            break;
//                        case 'C':
//                            typeName = [[NSString alloc] initWithFormat:@"unsigned char *[%llu]", length];
//                            break;
//                        case 'I':
//                            typeName = [[NSString alloc] initWithFormat:@"unsigned int *[%llu]", length];
//                            break;
//                        case 'S':
//                            typeName = [[NSString alloc] initWithFormat:@"unsigned short *[%llu]", length];
//                            break;
//                        case 'L':
//                            typeName = [[NSString alloc] initWithFormat:@"unsigned long *[%llu]", length];
//                            break;
//                        case 'Q':
//                            typeName = [[NSString alloc] initWithFormat:@"unsigned long long *[%llu]", length];
//                            break;
//                        case 'f':
//                            typeName = [[NSString alloc] initWithFormat:@"float *[%llu]", length];
//                            break;
//                        case 'd':
//                            typeName = [[NSString alloc] initWithFormat:@"double *[%llu]", length];
//                            break;
//                        case 'B':
//                            typeName = [[NSString alloc] initWithFormat:@"bool *[%llu]", length];
//                            break;
//                        case '*':
//                            typeName = [[NSString alloc] initWithFormat:@"char **[%llu]", length];
//                            break;
//                        case '@':
//                            typeName = [[NSString alloc] initWithFormat:@"id *[%llu]", length];
//                            break;
//                        case '#':
//                            typeName = [[NSString alloc] initWithFormat:@"Class *[%llu]", length];
//                            break;
//                        case ':':
//                            typeName = [[NSString alloc] initWithFormat:@"SEL *[%llu]", length];
//                            break;
//                        case '[':
//                            typeName = [[NSString alloc] initWithFormat:@"[] *[%llu]", length];
//                            break;
//                        case 'v':
//                            typeName = [[NSString alloc] initWithFormat:@"void *[%llu]", length];
//                            break;
//                        case '{':
//                            typeName = [[NSString alloc] initWithFormat:@"struct *[%llu]", length];
//                            break;
//                        case '(':
//                            typeName = [[NSString alloc] initWithFormat:@"union *[%llu]", length];
//                            break;
//                        case 'b':
//                            typeName = [[NSString alloc] initWithFormat:@"bit:n *[%llu]", length];
//                            break;
//                        case '^':
//                            typeName = [[NSString alloc] initWithFormat:@"** *[%llu]", length];
//                            break;
//                        case '?':
//                        default:
//                            typeName = [[NSString alloc] initWithFormat:@"? *[%llu]", length];
//                            break;
//                    }
//                }
//                    break;
//                case '?':
//                default:
//                    object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//                    typeName = [[NSString alloc] initWithFormat:@"?[%llu]", length];
//                    break;
//            }
//        }
//            break;
//        case '^':
//        {
//            NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:objCType]];
//            [scanner scanString:@"^" intoString:NULL];
//            
//            NSString *subtype;
//            [scanner scanUpToString:@"]" intoString:&subtype];
//            
//            const void *dereferencedValue = (* (void **)value);
//            object = (dereferencedValue
//                      ? [[NSString alloc] initWithFormat:@"<%p>", dereferencedValue]
//                      : @"NULL");
//            switch ([subtype characterAtIndex:0])
//            {
//                case 'c': typeName = @"char *"; break;
//                case 'i': typeName = @"int *"; break;
//                case 's': typeName = @"short *"; break;
//                case 'l': typeName = @"long *"; break;
//                case 'q': typeName = @"long long *"; break;
//                case 'C': typeName = @"unsigned char *"; break;
//                case 'I': typeName = @"unsigned int *"; break;
//                case 'S': typeName = @"unsigned short *"; break;
//                case 'L': typeName = @"unsigned long *"; break;
//                case 'Q': typeName = @"unsigned long long *"; break;
//                case 'f': typeName = @"float *"; break;
//                case 'd': typeName = @"double *"; break;
//                case 'B': typeName = @"bool *"; break;
//                case '*': typeName = @"char **"; break;
//                case '@': typeName = @"id *"; break;
//                case '#': typeName = @"Class *"; break;
//                case ':': typeName = @"SEL *"; break;
//                case '[': typeName = @"[] *"; break;
//                case 'v': typeName = @"void *"; break;
//                case '{': typeName = @"struct *"; break;
//                case '(': typeName = @"union *"; break;
//                case 'b': typeName = @"bit:n *"; break;
//                case '^': typeName = @"**"; break;
//                case '?':
//                default: typeName = @"? *"; break;
//            }
//        }
//            break;
//        case '?':
//        default:
//            object = [[NSValue alloc] initWithBytes:value objCType:objCType];
//            typeName = @"?";
//            break;
//    }
    
    NSString *valueString;
    NSString *typeName = _JREGetStringFromObjCType(objCType, value, 0, &valueString, NULL);
    
	NSLog(@"\n%s:%d : %s\n\t\"%s\" = (%@) %@\n",
          ((strrchr(filePath, '/') ?: filePath - 1) + 1),
          line,
          functionName,
          objectName,
          typeName,
          valueString);
}

void _JRELog(const char *filePath,
             int line,
             const char *functionName,
             NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
	NSLog(@"\n%s:%d : %s\n\t\%@\n",
          ((strrchr(filePath, '/') ?: filePath - 1) + 1),
          line,
          functionName,
          [[NSString alloc] initWithFormat:format arguments:arguments]);
	va_end(arguments);
}


