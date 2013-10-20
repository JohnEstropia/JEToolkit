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
unsigned long long _JRESizeOfObjCType(const char *objCType)
{
    switch (objCType[0])
    {
        case 'c': return sizeof(char);
        case 'i': return sizeof(int);
        case 's': return sizeof(short);
        case 'l': return sizeof(long);
        case 'q': return sizeof(long long);
        case 'C': return sizeof(unsigned char);
        case 'I': return sizeof(unsigned int);
        case 'S': return sizeof(unsigned short);
        case 'L': return sizeof(unsigned long);
        case 'Q': return sizeof(unsigned long long);
        case 'f': return sizeof(float);
        case 'd': return sizeof(double);
        case 'B': return sizeof(bool);
        case 'v': return sizeof(void);
        case '*': return sizeof(char *);
        case '@': return sizeof(id);
        case ':': return sizeof(SEL);
        case '^':
        case '?': return sizeof(void *);
        case '[':
        {
            NSString *substring = [[NSString alloc] initWithFormat:@"%s", (objCType + 1)];
            NSScanner *scanner = [[NSScanner alloc] initWithString:[substring substringToIndex:[substring rangeOfString:@"]" options:(NSLiteralSearch | NSBackwardsSearch)].location]];
            
            unsigned long long count = 0;
            [scanner scanUnsignedLongLong:&count];
            
            NSString *subtype;
            [scanner scanUpToString:@"\0" intoString:&subtype];
            
            unsigned long long size = _JRESizeOfObjCType([subtype UTF8String]);
            return (size * count);
        }
        case '{': // A structure
        case '(': // A union
        case 'b': // A bit field of num bits
            
        default: return 0;
    }
}

JRE_STATIC
NSString *_JREGetStringFromObjCType(const char *objCType,
                                    const void *value,
                                    const NSUInteger indentLevel,
                                    NSString *__autoreleasing *valueString)
{
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    
    const char *objCTypeIterator = objCType;
    char typePrefix = objCTypeIterator[0];
    while (typePrefix != '\0'
           && (typePrefix == 'r'
               || typePrefix == 'n'
               || typePrefix == 'N'
               || typePrefix == 'o'
               || typePrefix == 'O'
               || typePrefix == 'R'
               || typePrefix == 'V'))
    {
        objCTypeIterator++;
        
        if (!objCTypeIterator)
        {
            if (valueString)
            {
                (* valueString) = @"";
            }
            return @"";
        }
        
        typePrefix = objCTypeIterator[0];
    }
    
    objCTypeIterator++;
    
    NSString *outValueString;
    NSString *outTypeName;
    
    switch (typePrefix)
    {
        case 'c':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"'%1$c' (%1$i)", (* (char *)value)] : nil);
            outTypeName = @"char";
            break;
        }
        case 'i':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (int *)value))] : nil);
            outTypeName = @"int";
            break;
        }
        case 's':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (short *)value))] : nil);
            outTypeName = @"short";
            break;
        }
        case 'l':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (long *)value))] : nil);
            outTypeName = @"long";
            break;
        }
        case 'q':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (long long *)value))] : nil);
            outTypeName = @"long long";
            break;
        }
        case 'C':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (unsigned char *)value))] : nil);
            outTypeName = @"unsigned char";
            break;
        }
        case 'I':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (unsigned int *)value))] : nil);
            outTypeName = @"unsigned int";
            break;
        }
        case 'S':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (unsigned short *)value))] : nil);
            outTypeName = @"unsigned short";
            break;
        }
        case 'L':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (unsigned long *)value))] : nil);
            outTypeName = @"unsigned long";
            break;
        }
        case 'Q':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (unsigned long long *)value))] : nil);
            outTypeName = @"unsigned long long";
            break;
        }
        case 'f':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (float *)value))] : nil);
            outTypeName = @"float";
            break;
        }
        case 'd':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (double *)value))] : nil);
            outTypeName = @"double";
            break;
        }
        case 'B':
        {
            outValueString = (valueString ? [NSString stringWithFormat:@"%@", @((* (bool *)value))] : nil);
            outTypeName = @"bool";
            break;
        }
        case '*':
        {
            if (valueString)
            {
                const char *dereferencedValue = (* (char **)value);
                outValueString = (dereferencedValue
                                  ? [NSString stringWithFormat:@"<%1$p> \"%1$s\"", dereferencedValue]
                                  : @"NULL");
            }
            outTypeName = @"char *";
            break;
        }
        case '@':
        {
            const id dereferencedValue = (id)(* (__unsafe_unretained id *)value);
            if (valueString)
            {
                if (!dereferencedValue)
                {
                    outValueString = @"nil";
                }
                else if ([dereferencedValue isKindOfClass:[NSError class]])
                {
                    outValueString = [NSString stringWithFormat:@"%@", [(NSError *)dereferencedValue userInfo]];
                }
                else
                {
                    outValueString = [NSString stringWithFormat:@"%@", [dereferencedValue debugDescription]];
                }
            }
            outTypeName = (dereferencedValue
                           ? [NSString stringWithFormat:@"%@ *", [dereferencedValue class]]
                           : @"id");
            break;
        }
        case '#':
        {
            if (valueString)
            {
                const Class dereferencedValue = (* (Class *)value);
                outValueString = (NSStringFromClass(dereferencedValue) ?: @"Nil");
            }
            outTypeName = @"Class";
            break;
        }
        case ':':
        {
            if (valueString)
            {
                const SEL dereferencedValue = (* (SEL *)value);
                outValueString = (NSStringFromSelector(dereferencedValue) ?: @"NULL");
            }
            outTypeName = @"SEL";
            break;
        }
        case 'v':
        {
            outTypeName = @"void";
            break;
        }
        case 'b':
        {
            NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:objCTypeIterator]];
            
            unsigned long long bitCount = 0;
            [scanner scanUnsignedLongLong:&bitCount];
            
            outValueString = (valueString ? @"..." : nil);
            outTypeName = [NSString stringWithFormat:@"bit:%llu", bitCount];
            break;
        }
        case '{':
        {
            NSString *substring = [[NSString alloc] initWithFormat:@"%s", objCTypeIterator];
            NSScanner *scanner = [[NSScanner alloc] initWithString:[substring substringToIndex:[substring rangeOfString:@"}" options:(NSLiteralSearch | NSBackwardsSearch)].location]];
            
            NSString *structName;
            [scanner scanUpToString:@"=" intoString:&structName];
            
            if (valueString)
            {
                NSString *subtype;
                [scanner scanUpToString:@"\0" intoString:&subtype];
                
                if ([structName hasPrefix:@"CG"])
                {
                    if ([structName isEqualToString:@"CGPoint"])
                    {
                        outValueString = NSStringFromCGPoint(* (CGPoint *)value);
                    }
                    else if ([structName isEqualToString:@"CGSize"])
                    {
                        outValueString = NSStringFromCGSize(* (CGSize *)value);
                    }
                    else if ([structName isEqualToString:@"CGRect"])
                    {
                        outValueString = NSStringFromCGRect(* (CGRect *)value);
                    }
                    else if ([structName isEqualToString:@"CGAffineTransform"])
                    {
                        outValueString = NSStringFromCGAffineTransform(* (CGAffineTransform *)value);
                    }
                }
                else if ([structName hasPrefix:@"UI"])
                {
                    if ([structName isEqualToString:@"UIEdgeInsets"])
                    {
                        outValueString = NSStringFromUIEdgeInsets(* (UIEdgeInsets *)value);
                    }
                    else if ([structName isEqualToString:@"UIOffset"])
                    {
                        outValueString = NSStringFromUIOffset(* (UIOffset *)value);
                    }
                }
                else if ([structName isEqualToString:@"_NSRange"])
                {
                    outValueString = NSStringFromRange(* (NSRange *)value);
                }
                
                if (!outValueString)
                {
                    NSValue *structValue = [[NSValue alloc] initWithBytes:value objCType:objCType];
                    if (structValue)
                    {
                        outValueString = [NSString stringWithFormat:@"{ %@ }", [structValue debugDescription]];
                    }
                    else
                    {
                        outValueString = @"{ ... }"; // NSValue cannot handle bitfields
                    }
                }
            }
            
            outTypeName = [NSString stringWithFormat:@"struct %@", structName];
            break;
        }
        case '(':
        {
            NSString *substring = [[NSString alloc] initWithFormat:@"%s", objCTypeIterator];
            NSScanner *scanner = [[NSScanner alloc] initWithString:[substring substringToIndex:[substring rangeOfString:@")" options:(NSLiteralSearch | NSBackwardsSearch)].location]];
            
            NSString *structName;
            [scanner scanUpToString:@"=" intoString:&structName];
            
            if (valueString)
            {
                NSString *subtype;
                [scanner scanUpToString:@"\0" intoString:&subtype];
                
                NSValue *unionValue = [[NSValue alloc] initWithBytes:value objCType:objCType];
                if (unionValue)
                {
                    outValueString = [NSString stringWithFormat:@"{ %@ }", [unionValue debugDescription]];
                }
                else
                {
                    outValueString = @"{ ... }"; // NSValue cannot handle bitfields
                }
            }
            
            outTypeName = [NSString stringWithFormat:@"union %@", structName];
            break;
        }
        case '^':
        {
            NSScanner *scanner = [[NSScanner alloc] initWithString:
                                  [[NSString alloc] initWithFormat:@"%s", objCTypeIterator]];
            NSString *subtype;
            [scanner scanUpToString:@"\0" intoString:&subtype];
            
            const void *dereferencedValue = (* (void **)value);
            if (valueString)
            {
                outValueString = (dereferencedValue
                                  ? [NSString stringWithFormat:@"<%p>", dereferencedValue]
                                  : @"NULL");
            }
            
            outTypeName = [NSString stringWithFormat:
                           @"%@ *",
                           _JREGetStringFromObjCType([subtype UTF8String],
                                                     dereferencedValue,
                                                     (indentLevel + 1),
                                                     NULL)];
            break;
        }
        case '[':
        {
            NSString *substring = [[NSString alloc] initWithFormat:@"%s", objCTypeIterator];
            NSScanner *scanner = [[NSScanner alloc] initWithString:[substring substringToIndex:[substring rangeOfString:@"]" options:(NSLiteralSearch | NSBackwardsSearch)].location]];
            
            unsigned long long count = 0;
            [scanner scanUnsignedLongLong:&count];
            
            NSString *subtype;
            [scanner scanUpToString:@"\0" intoString:&subtype];
            
            const void *dereferencedValue = (* (void **)value);
            const char *objCSubType = [subtype UTF8String];
            unsigned long long sizePerSubelement = _JRESizeOfObjCType(objCSubType);
            if (valueString)
            {
                NSMutableString *arrayString = [[NSMutableString alloc] init];
                for (unsigned long long i = 0; i < count; ++i)
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
//                     _JREGetStringFromObjCType(objCSubType,
//                                               ((indentLevel == 0 || objCSubType[0] == '[')
//                                                ? (dereferencedValue + (i * sizePerSubelement))
//                                                : (value + (i * sizePerSubelement))),
//                                               (indentLevel + 1),
//                                               &itemString)];
                    _JREGetStringFromObjCType(objCSubType,
                                              (value + (i * sizePerSubelement)),
                                              (indentLevel + 1),
                                              &itemString)];
                    [arrayString appendFormat:@"%@,\n", itemString];
                    
                    for (NSUInteger indent = 0; indent <= indentLevel; ++indent)
                    {
                        [arrayString appendString:@"\t"];
                    }
                }
                
                outValueString = [NSString stringWithFormat:
                                  @"%@ [%@]",
                                  (dereferencedValue
                                   ? [[NSString alloc] initWithFormat:@"<%p>", dereferencedValue]
                                   : @"NULL"),
                                  arrayString];
            }
            
            outTypeName = [NSString stringWithFormat:
                           @"%@[%llu]",
                           _JREGetStringFromObjCType([subtype UTF8String],
                                                     value,
                                                     (indentLevel + 1),
                                                     NULL),
                           count];
            break;
        }
        case '?':
        {
            outTypeName = @"func";
            break;
        }
        default:
        {
            break;
        }
    }
    
    if (valueString)
    {
        (* valueString) = (outValueString ?: @"");
    }
    return (outTypeName ?: @"");
}


#pragma mark - public

void _JRELogObject(const char *filePath,
                   int line,
                   const char *functionName,
                   const char *objectName,
                   const void *value,
                   const char *objCType)
{
    @autoreleasepool {
        
        NSString *valueString;
        NSString *typeName = _JREGetStringFromObjCType(objCType,
                                                       value,
                                                       0,
                                                       &valueString);
        NSLog(@"\n%s:%d : %s\n>\t\"%s\" = (%@) %@\n\n",
              ((strrchr(filePath, '/') ?: filePath - 1) + 1),
              line,
              functionName,
              objectName,
              typeName,
              valueString);
        
    }
}

void _JRELogFormat(const char *filePath,
                   int line,
                   const char *functionName,
                   NSString *format, ...)
{
    va_list arguments;
    va_start(arguments, format);
	NSLog(@"\n%s:%d : %s\n>\t\%@\n",
          ((strrchr(filePath, '/') ?: filePath - 1) + 1),
          line,
          functionName,
          [[NSString alloc] initWithFormat:format arguments:arguments]);
	va_end(arguments);
}


