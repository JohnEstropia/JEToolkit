//
//  NSValue+JEDebugging.m
//  JEToolkit
//
//  Created by DIT John Estropia on 2013/11/26.
//  Copyright (c) 2013年 John Rommel Estropia. All rights reserved.
//

#import "NSValue+JEDebugging.h"

#import <objc/runtime.h>

#import "JECompilerDefines.h"
#import "NSObject+JEDebugging.h"
#import "NSMutableString+JEDebugging.h"


@implementation NSValue (JEDebugging)

#pragma mark - NSObject+JEDebugging

- (NSMutableString *)detailedDescriptionIncludeClass:(BOOL)includeClass
                                      includeAddress:(BOOL)includeAddress
{
    NSMutableString *typeNameBuilder = [[NSMutableString alloc] init];
    NSMutableString *valueStringBuilder = [[NSMutableString alloc] init];
    
    [NSValue inspectValue:self
         expectedObjCType:[self objCType]
          typeNameBuilder:typeNameBuilder
       valueStringBuilder:valueStringBuilder];
    
    NSMutableString *description = [[NSMutableString alloc] initWithFormat:
                                    @"(%@) %@",
                                    typeNameBuilder,
                                    valueStringBuilder];
    if (includeAddress)
    {
        [description insertString:[NSString stringWithFormat:@"<%p> ", self] atIndex:0];
    }
    if (includeClass)
    {
        [description insertString:[NSString stringWithFormat:@"(%@ *) ", [self class]] atIndex:0];
    }
    
    [valueStringBuilder indentByLevel:1];
    
    return valueStringBuilder;
}


#pragma mark - private

+ (NSNumberFormatter *)integerFormatter
{
    static NSNumberFormatter *integerFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        integerFormatter = formatter;
        
    });
    return integerFormatter;
}

+ (void)inspectValue:(NSValue *)wrappedValue
    expectedObjCType:(const char *)objCType
     typeNameBuilder:(NSMutableString *)typeNameBuilder
  valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    if (!objCType || strlen(objCType) < 1)
    {
        [self
         inspectUndefinedValue:wrappedValue
         typeNameBuilder:typeNameBuilder];
        return;
    }
    
    switch (objCType[0])
    {
        case _C_ID:
            [self
             inspectIdValue:wrappedValue
             expectedObjCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_CLASS:
            [self
             inspectClassValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_SEL:
            [self
             inspectSelectorValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_CHR:
            [self
             inspectCharValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UCHR:
            [self
             inspectUnsignedCharValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_SHT:
            [self
             inspectShortValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_USHT:
            [self
             inspectUnsignedShortValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_INT:
            [self
             inspectIntValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UINT:
            [self
             inspectUnsignedIntValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_LNG:
            [self
             inspectLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_ULNG:
            [self
             inspectUnsignedLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_LNG_LNG:
            [self
             inspectLongLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_ULNG_LNG:
            [self
             inspectUnsignedLongLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_FLT:
            [self
             inspectFloatValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_DBL:
            [self
             inspectDoubleValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case 'D':
            [self
             inspectLongDoubleValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_BFLD:
            [self
             inspectBitFieldValue:wrappedValue
             objCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_BOOL:
            [self
             inspectBoolValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_VOID:
            [self
             inspectVoidValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_PTR:
            [self
             inspectPointerValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_CHARPTR:
            [self
             inspectCStringValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_ARY_B:
            [self
             inspectArrayValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UNION_B:
            [self
             inspectUnionValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_STRUCT_B:
            [self
             inspectStructValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UNDEF:
        case _C_ATOM:
        case _C_VECTOR:
        default:
            [self
             inspectUndefinedValue:wrappedValue
             typeNameBuilder:typeNameBuilder];
            break;
    }
}

+ (void)inspectIdValue:(NSValue *)wrappedValue
      expectedObjCType:(const char *)objCType
       typeNameBuilder:(NSMutableString *)typeNameBuilder
    valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    id __unsafe_unretained idValue = nil;
    [wrappedValue getValue:&idValue];
    
    if (idValue)
    {
        [typeNameBuilder appendFormat:@"%@ *", [idValue class]];
    }
    else
    {
        [typeNameBuilder appendString:@"id"];
    }
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    if (!idValue)
    {
        [valueStringBuilder appendString:@"nil"];
        return;
    }
    
    [valueStringBuilder appendFormat:@"<%p> ", idValue];
    
    if ((strlen(objCType) > 1) && (objCType[1] == _C_UNDEF))
    {
        struct _JEBlockLiteral
        {
            Class isa;
            int flags;
            int reserved;
            void (*invoke)(void *, ...);
            struct _JEBlockDescriptor
            {
                unsigned long int reserved;
                unsigned long int size;
                const void (*copyHelper)(void *dst, void *src); // IFF (1<<25)
                const void (*disposeHelper)(void *src);         // IFF (1<<25)
                const char *signature;                          // IFF (1<<30)
            } *descriptor;
        };
        
        typedef NS_OPTIONS(NSUInteger, _JEBlockDescriptionFlags)
        {
            _JEBlockDescriptionFlagsHasCopyDispose  = (1 << 25),
            _JEBlockDescriptionFlagsHasCtor         = (1 << 26), // helpers have C++ code
            _JEBlockDescriptionFlagsIsGlobal        = (1 << 28),
            _JEBlockDescriptionFlagsHasStret        = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
            _JEBlockDescriptionFlagsHasSignature    = (1 << 30)
        };
        
        struct _JEBlockLiteral *blockRef = (__bridge struct _JEBlockLiteral *)idValue;
        _JEBlockDescriptionFlags blockFlags = blockRef->flags;
        
        if (blockFlags & _JEBlockDescriptionFlagsHasSignature)
        {
            const void *signatureLocation = blockRef->descriptor;
            signatureLocation += sizeof(typeof(blockRef->descriptor->reserved));
            signatureLocation += sizeof(typeof(blockRef->descriptor->size));
            
            if (blockFlags & _JEBlockDescriptionFlagsHasCopyDispose) {
                signatureLocation += sizeof(typeof(blockRef->descriptor->copyHelper));
                signatureLocation += sizeof(typeof(blockRef->descriptor->disposeHelper));
            }
            
            const char *signature = (*(const char **)signatureLocation);
            NSMethodSignature *blockSignature = [NSMethodSignature signatureWithObjCTypes:signature];
            
            @autoreleasepool {
                
                [valueStringBuilder appendString:@" "];
                [self
                 inspectValue:nil
                 expectedObjCType:[blockSignature methodReturnType]
                 typeNameBuilder:valueStringBuilder
                 valueStringBuilder:NULL];
                [valueStringBuilder appendString:@"(^)"];
                
            }
            
            NSUInteger argCount = [blockSignature numberOfArguments];
            if (argCount <= 1)
            {
                [valueStringBuilder appendFormat:@"(void)"];
            }
            else
            {
                [valueStringBuilder appendString:@"("];
                
                for (NSUInteger i = 1; i < argCount; ++i)
                {
                    @autoreleasepool {
                        
                        if (i > 1)
                        {
                            [valueStringBuilder appendString:@","];
                        }
                        
                        [self
                         inspectValue:nil
                         expectedObjCType:[blockSignature getArgumentTypeAtIndex:i]
                         typeNameBuilder:valueStringBuilder
                         valueStringBuilder:NULL];
                        
                    }
                }
                [valueStringBuilder appendString:@")"];
            }
        }
    }
    else
    {
        NSMutableString *detailedDescription = [idValue detailedDescriptionIncludeClass:NO includeAddress:NO];
        [detailedDescription indentByLevel:1];
        [valueStringBuilder appendString:detailedDescription];
    }
}

+ (void)inspectClassValue:(NSValue *)wrappedValue
          typeNameBuilder:(NSMutableString *)typeNameBuilder
       valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"Class"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    Class classValue = Nil;
    [wrappedValue getValue:&classValue];
    [valueStringBuilder appendString:(NSStringFromClass(classValue) ?: @"Nil")];
}

+ (void)inspectSelectorValue:(NSValue *)wrappedValue
             typeNameBuilder:(NSMutableString *)typeNameBuilder
          valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"SEL"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    SEL selectorValue = NULL;
    [wrappedValue getValue:&selectorValue];
    [valueStringBuilder appendString:(NSStringFromSelector(selectorValue) ?: @"NULL")];
}

+ (void)inspectCharValue:(NSValue *)wrappedValue
         typeNameBuilder:(NSMutableString *)typeNameBuilder
      valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"char"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    char charValue = '\0';
    [wrappedValue getValue:&charValue];
    
    NSString *charMapping = [NSMutableString CStringBackslashEscapeMapping][[[NSString alloc]
                                                                             initWithCharacters:&(const unichar){ charValue }
                                                                             length:1]];
    if (charMapping)
    {
        [valueStringBuilder appendFormat:@"'%@' (%i)", charMapping, charValue];
    }
    else
    {
        [valueStringBuilder appendFormat:@"'%1$c' (%1$i)", charValue];
    }
}

+ (void)inspectUnsignedCharValue:(NSValue *)wrappedValue
                 typeNameBuilder:(NSMutableString *)typeNameBuilder
              valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"unsigned char"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    unsigned char unsignedCharValue = 0;
    [wrappedValue getValue:&unsignedCharValue];
    [valueStringBuilder appendFormat:@"%uc", unsignedCharValue];
}

+ (void)inspectShortValue:(NSValue *)wrappedValue
          typeNameBuilder:(NSMutableString *)typeNameBuilder
       valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"short"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    short shortValue = 0;
    [wrappedValue getValue:&shortValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(shortValue)]];
}

+ (void)inspectUnsignedShortValue:(NSValue *)wrappedValue
                  typeNameBuilder:(NSMutableString *)typeNameBuilder
               valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"unsigned short"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    unsigned short unsignedShortValue = 0;
    [wrappedValue getValue:&unsignedShortValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(unsignedShortValue)]];
}

+ (void)inspectIntValue:(NSValue *)wrappedValue
        typeNameBuilder:(NSMutableString *)typeNameBuilder
     valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"int"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    int intValue = 0;
    [wrappedValue getValue:&intValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(intValue)]];
}

+ (void)inspectUnsignedIntValue:(NSValue *)wrappedValue
                typeNameBuilder:(NSMutableString *)typeNameBuilder
             valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"unsigned int"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    unsigned int unsignedIntValue = 0;
    [wrappedValue getValue:&unsignedIntValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(unsignedIntValue)]];
}

+ (void)inspectLongValue:(NSValue *)wrappedValue
         typeNameBuilder:(NSMutableString *)typeNameBuilder
      valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"long"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    long longValue = 0;
    [wrappedValue getValue:&longValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(longValue)]];
}

+ (void)inspectUnsignedLongValue:(NSValue *)wrappedValue
                 typeNameBuilder:(NSMutableString *)typeNameBuilder
              valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"unsigned long"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    unsigned long unsignedLongValue = 0;
    [wrappedValue getValue:&unsignedLongValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(unsignedLongValue)]];
}

+ (void)inspectLongLongValue:(NSValue *)wrappedValue
             typeNameBuilder:(NSMutableString *)typeNameBuilder
          valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"long long"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    long long longlongValue = 0;
    [wrappedValue getValue:&longlongValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(longlongValue)]];
}

+ (void)inspectUnsignedLongLongValue:(NSValue *)wrappedValue
                     typeNameBuilder:(NSMutableString *)typeNameBuilder
                  valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"unsigned long long"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    unsigned long long unsignedLonglongValue = 0;
    [wrappedValue getValue:&unsignedLonglongValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(unsignedLonglongValue)]];
}

+ (void)inspectFloatValue:(NSValue *)wrappedValue
          typeNameBuilder:(NSMutableString *)typeNameBuilder
       valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"float"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    float floatValue = 0.0f;
    [wrappedValue getValue:&floatValue];
    
    static const NSInteger _JREDecimalDigits = 9;
    
    if (floatValue >= (powf(10.0f, (_JREDecimalDigits - 1))))
    {
        [valueStringBuilder appendFormat:@"%.*e", FLT_DIG, floatValue];
    }
    else
    {
        [valueStringBuilder appendFormat:@"%.*g", _JREDecimalDigits, floatValue];
    }
}

+ (void)inspectDoubleValue:(NSValue *)wrappedValue
           typeNameBuilder:(NSMutableString *)typeNameBuilder
        valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"double"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    double doubleValue = 0.0;
    [wrappedValue getValue:&doubleValue];
    
    static const NSInteger _JREDecimalDigits = 17;
    
    if (doubleValue >= (pow(10.0, (_JREDecimalDigits - 1))))
    {
        [valueStringBuilder appendFormat:@"%.*e", DBL_DIG, doubleValue];
    }
    else
    {
        [valueStringBuilder appendFormat:@"%.*g", _JREDecimalDigits, doubleValue];
    }
}

+ (void)inspectLongDoubleValue:(NSValue *)wrappedValue
               typeNameBuilder:(NSMutableString *)typeNameBuilder
            valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"long double"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    long double longDoubleValue = 0.0l;
    [wrappedValue getValue:&longDoubleValue];
    
    static const NSInteger _JREDecimalDigits = 21;
    
    if (longDoubleValue >= (powl(10.0l, (_JREDecimalDigits - 1))))
    {
        [valueStringBuilder appendFormat:@"%.*Le", LDBL_DIG, longDoubleValue];
    }
    else
    {
        [valueStringBuilder appendFormat:@"%.*Lg", _JREDecimalDigits, longDoubleValue];
    }
}

+ (void)inspectBitFieldValue:(NSValue *)wrappedValue
            expectedObjCType:(const char *)objCType
             typeNameBuilder:(NSMutableString *)typeNameBuilder
          valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:(objCType + 1)]];
    
    unsigned long long bitCount = 0;
    [scanner scanUnsignedLongLong:&bitCount];
    
    [typeNameBuilder appendFormat:@"%llubit", bitCount];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    // https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Conceptual/Archiving/Articles/codingctypes.html
    unsigned long long bitFieldValue = 0;
    [wrappedValue getValue:&bitFieldValue];
    
    const unsigned long long shiftCount = (sizeof(bitFieldValue) - bitCount);
    bitFieldValue = ((bitFieldValue << shiftCount) >> shiftCount);
    
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(bitFieldValue)]];
}

+ (void)inspectBoolValue:(NSValue *)wrappedValue
         typeNameBuilder:(NSMutableString *)typeNameBuilder
      valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"bool"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    bool boolValue = false;
    [wrappedValue getValue:&boolValue];
    [valueStringBuilder appendString:(boolValue ? @"true" : @"false")];
}

+ (void)inspectVoidValue:(NSValue *)wrappedValue
         typeNameBuilder:(NSMutableString *)typeNameBuilder
      valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"void"];
}

+ (void)inspectUndefinedValue:(NSValue *)wrappedValue
              typeNameBuilder:(NSMutableString *)typeNameBuilder
{
    [typeNameBuilder appendString:@"?"];
}

+ (void)inspectPointerValue:(NSValue *)wrappedValue
           expectedObjCType:(const char *)objCType
                indentLevel:(NSUInteger)indentLevel
            typeNameBuilder:(NSMutableString *)typeNameBuilder
         valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    const void *pointerValue = NULL;
    [wrappedValue getValue:&pointerValue];
    
    objCType += 1;
    if (objCType[0] == _C_UNDEF)
    {
        [typeNameBuilder appendString:@"func *"];
        
        if (!valueStringBuilder)
        {
            return;
        }
        
        if (pointerValue)
        {
            [valueStringBuilder appendFormat:@"<%p>", pointerValue];
        }
        else
        {
            [valueStringBuilder appendString:@"NULL"];
        }
    }
    else
    {
        if (pointerValue)
        {
            [valueStringBuilder appendFormat:@"<%p> ", pointerValue];
        }
        else
        {
            [valueStringBuilder appendString:@"NULL"];
        }
        
        [self
         inspectValue:(pointerValue
                       ? [[NSValue alloc] initWithBytes:pointerValue objCType:objCType]
                       : nil)
         objCType:objCType
         indentLevel:indentLevel
         typeNameBuilder:typeNameBuilder
         valueStringBuilder:(pointerValue ? valueStringBuilder : nil)];
        
        [typeNameBuilder appendString:([typeNameBuilder hasSuffix:@"*"]
                                       ? @"*"
                                       : @" *")];
    }
}

+ (void)inspectCStringValue:(NSValue *)wrappedValue
            typeNameBuilder:(NSMutableString *)typeNameBuilder
         valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"char *"];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    const char *cstringValue = NULL;
    [wrappedValue getValue:&cstringValue];
    
    if (cstringValue)
    {
        [valueStringBuilder appendFormat:@"<%1$p> \"%1$s\"", cstringValue];
    }
    else
    {
        [valueStringBuilder appendString:@"NULL"];
    }
}

+ (void)inspectAtomValue:(NSValue *)wrappedValue
         typeNameBuilder:(NSMutableString *)typeNameBuilder
      valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    [typeNameBuilder appendString:@"atom"];
}

+ (void)inspectArrayValue:(NSValue *)wrappedValue
                 objCType:(const char *)objCType
              indentLevel:(NSUInteger)indentLevel
          typeNameBuilder:(NSMutableString *)typeNameBuilder
       valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_ARY_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    unsigned long long count = 0;
    [scanner scanUnsignedLongLong:&count];
    
    NSString *subtype;
    [scanner scanUpToString:@"\0" intoString:&subtype];
    
    const char *objCSubType = [subtype UTF8String];
    
    [self
     inspectValue:nil
     objCType:objCSubType
     indentLevel:(indentLevel + 1)
     typeNameBuilder:typeNameBuilder
     valueStringBuilder:NULL];
    
    [typeNameBuilder appendFormat:@"[%llu]", count];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    NSUInteger arraySize = 0;
    NSUInteger arrayAlignedSize = 0;
    NSGetSizeAndAlignment(objCType, &arraySize, &arrayAlignedSize);
    
    unsigned long long sizePerSubelement = (arraySize / count);
    
    void *arrayValue = calloc((size_t)count, (size_t)sizePerSubelement);
    [wrappedValue getValue:arrayValue];
    
    NSString *indentString = [self indentationWithLevel:indentLevel];
    
    [valueStringBuilder appendString:@"["];
    for (unsigned long long i = 0; i < count; ++i)
    {
        if (i == 0)
        {
            [valueStringBuilder appendString:@"\n"];
            [valueStringBuilder appendString:indentString];
        }
        
        NSValue *itemValue = [[NSValue alloc]
                              initWithBytes:(arrayValue + (i * sizePerSubelement))
                              objCType:objCSubType];
        
        @autoreleasepool {
            
            [valueStringBuilder appendFormat:@"  [%llu]: (", i];
            
            NSMutableString *itemValueString = [[NSMutableString alloc] init];
            [self
             inspectValue:itemValue
             objCType:objCSubType
             indentLevel:(indentLevel + 1)
             typeNameBuilder:valueStringBuilder
             valueStringBuilder:itemValueString];
            
            [valueStringBuilder appendString:@") "];
            [valueStringBuilder appendString:itemValueString];
            [valueStringBuilder appendString:@",\n"];
            
        }
        
        [valueStringBuilder appendString:indentString];
    }
    free(arrayValue);
    
    [valueStringBuilder appendString:@"]"];
}

+ (void)inspectUnionValue:(NSValue *)wrappedValue
                 objCType:(const char *)objCType
              indentLevel:(NSUInteger)indentLevel
          typeNameBuilder:(NSMutableString *)typeNameBuilder
       valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_UNION_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    [typeNameBuilder appendFormat:@"union %@", structName];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    //    NSString *subtype;
    //    [scanner scanUpToString:@"\0" intoString:&subtype];
    
    if (wrappedValue)
    {
        [valueStringBuilder appendFormat:@"{ %@ }", [wrappedValue debugDescription]];
    }
    else
    {
        [valueStringBuilder appendString:@"{ ... }"];
    }
}

+ (void)inspectStructValue:(NSValue *)wrappedValue
                  objCType:(const char *)objCType
               indentLevel:(NSUInteger)indentLevel
           typeNameBuilder:(NSMutableString *)typeNameBuilder
        valueStringBuilder:(NSMutableString *)valueStringBuilder
{
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_STRUCT_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    [typeNameBuilder appendFormat:@"struct %@", structName];
    
    if (!valueStringBuilder)
    {
        return;
    }
    
    static NSMutableDictionary *structHandlers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSMutableDictionary *blockDictionary = [[NSMutableDictionary alloc] init];
        blockDictionary[@(@encode(CGPoint))] = [^ NSString *(NSValue *structValue){
            
            CGPoint point = [structValue CGPointValue];
            return [NSString stringWithFormat:
                    @"{\n"
                    "  x: (float) %g,\n"
                    "  y: (float) %g\n"
                    "}",
                    point.x,
                    point.y];
            
        } copy];
        blockDictionary[@(@encode(CGSize))] = [^ NSString *(NSValue *structValue){
            
            CGSize size = [structValue CGSizeValue];
            return [NSString stringWithFormat:
                    @"{\n"
                    "  width: (float) %g,\n"
                    "  height: (float) %g\n"
                    "}",
                    size.width,
                    size.height];
            
        } copy];
        blockDictionary[@(@encode(CGRect))] = [^ NSString *(NSValue *structValue){
            
            CGRect rect = [structValue CGRectValue];
            return [NSString stringWithFormat:
                    @"{\n"
                    "  x: (float) %g,\n"
                    "  y: (float) %g,\n"
                    "  width: (float) %g,\n"
                    "  height: (float) %g\n"
                    "}",
                    rect.origin.x,
                    rect.origin.y,
                    rect.size.width,
                    rect.size.height];
            
        } copy];
        blockDictionary[@(@encode(CGAffineTransform))] = [^ NSString *(NSValue *structValue){
            
            CGAffineTransform affineTransform = [structValue CGAffineTransformValue];
            return [NSString stringWithFormat:
                    @"{\n"
                    "  a: (float) %g,\n"
                    "  b: (float) %g,\n"
                    "  c: (float) %g,\n"
                    "  d: (float) %g,\n"
                    "  tx: (float) %g,\n"
                    "  ty: (float) %g\n"
                    "}",
                    affineTransform.a,
                    affineTransform.b,
                    affineTransform.c,
                    affineTransform.d,
                    affineTransform.tx,
                    affineTransform.ty];
            
        } copy];
        blockDictionary[@(@encode(UIEdgeInsets))] = [^ NSString *(NSValue *structValue){
            
            UIEdgeInsets edgeInsets = [structValue UIEdgeInsetsValue];
            return [NSString stringWithFormat:
                    @"{\n"
                    "  top: (float) %g,\n"
                    "  left: (float) %g,\n"
                    "  bottom: (float) %g,\n"
                    "  right: (float) %g\n"
                    "}",
                    edgeInsets.top,
                    edgeInsets.left,
                    edgeInsets.bottom,
                    edgeInsets.right];
            
        } copy];
        blockDictionary[@(@encode(UIOffset))] = [^ NSString *(NSValue *structValue){
            
            UIOffset offset = [structValue UIOffsetValue];
            return [NSString stringWithFormat:
                    @"{\n"
                    "  horizontal: (float) %g,\n"
                    "  vertical: (float) %g\n"
                    "}",
                    offset.horizontal,
                    offset.vertical];
            
        } copy];
        blockDictionary[@(@encode(NSRange))] = [^ NSString *(NSValue *structValue){
            
            NSRange range = [structValue rangeValue];
            return [NSString stringWithFormat:
                    @"{\n"
                    "  location: (unsigned int) %lu,\n"
                    "  length: (unsigned int) %lu\n"
                    "}",
                    (unsigned long)range.location,
                    (unsigned long)range.length];
            
        } copy];
        
        structHandlers = blockDictionary;
        
    });
    
    NSString *(^getStructString)(NSValue *structValue) = structHandlers[@(objCType)];
    if (getStructString)
    {
        NSMutableString *structString = [NSMutableString stringWithString:getStructString(wrappedValue)];
        [self indentString:structString withLevel:indentLevel];
        
        [valueStringBuilder appendString:structString];
    }
    else if (wrappedValue)
    {
        [valueStringBuilder appendFormat:@"{ %@ }", [wrappedValue debugDescription]];
    }
    else
    {
        [valueStringBuilder appendString:@"{ ... }"];
    }
}


@end
