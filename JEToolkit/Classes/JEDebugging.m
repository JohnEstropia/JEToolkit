//
//  JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEDebugging.h"

#import <objc/runtime.h>


@implementation JEDebugging

#pragma mark - private

#pragma mark Shared Objects

+ (dispatch_queue_t)barrierQueue
{
    static dispatch_queue_t barrierQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        barrierQueue = dispatch_queue_create("JEDebugging.barrierQueue", DISPATCH_QUEUE_CONCURRENT);
        
    });
    
    return barrierQueue;
}

+ (NSNumberFormatter *)defaultIntegerFormatter
{
	static NSNumberFormatter *defaultIntegerFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        defaultIntegerFormatter = formatter;
		
	});
	return defaultIntegerFormatter;
}

+ (NSNumberFormatter *)defaultDoubleFormatter
{
	static NSNumberFormatter *defaultDoubleFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
		[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setMinimumIntegerDigits:1];
        [formatter setMaximumIntegerDigits:309];
        [formatter setMinimumFractionDigits:1];
        [formatter setMaximumFractionDigits:309];
        [formatter setUsesSignificantDigits:NO];
        [formatter setGeneratesDecimalNumbers:YES];
        defaultDoubleFormatter = formatter;
		
	});
	return defaultDoubleFormatter;
}

#pragma mark Utilities

+ (const char *)objCTypeByIgnoringModifiers:(const char *)objCType
{
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    
    while (objCType != NULL && objCType[0] != '\0')
    {
        const char typeModifier = objCType[0];
        if (typeModifier != 'r'     // const
            && typeModifier != 'n'  // in
            && typeModifier != 'N'  // inout
            && typeModifier != 'o'  // out
            && typeModifier != 'O'  // bycopy
            && typeModifier != 'R'  // byref
            && typeModifier != 'V') // oneway
        {
            break;
        }
        objCType++;
    }
    return objCType;
}

+ (NSString *)indentStringWithLevel:(NSUInteger)indentLevel
{
    return [[NSString string]
            stringByPaddingToLength:(indentLevel + 2)
            withString:@"\t"
            startingAtIndex:0];
}

+ (NSString *)indentString:(NSString *)string withLevel:(NSUInteger)indentLevel
{
    return [string
            stringByReplacingOccurrencesOfString:@"\n"
            withString:[@"\n"
                        stringByPaddingToLength:(indentLevel + 3)
                        withString:@"\t"
                        startingAtIndex:0]
            options:(NSCaseInsensitiveSearch | NSLiteralSearch)
            range:(NSRange){ .location = 0, .length = [string length] }];
}

#pragma mark id handlers

+ (void)inspectNSBlock:(id)block
           indentLevel:(NSUInteger)indentLevel
           valueString:(NSString *__autoreleasing *)valueString
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
    
    struct _JEBlockLiteral *blockRef = (__bridge struct _JEBlockLiteral *)block;
    _JEBlockDescriptionFlags blockFlags = blockRef->flags;
    
    NSMutableString *blockSignatureString = [[NSMutableString alloc] init];
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
            
            NSString *argTypeName;
            NSString *argDummyValueString;
            [self
             inspectValue:nil
             objCType:[blockSignature methodReturnType]
             indentLevel:0
             typeName:&argTypeName
             valueString:&argDummyValueString];
            [blockSignatureString appendFormat:@" %@(^)", argTypeName];
            
        }
        
        NSUInteger argCount = [blockSignature numberOfArguments];
        if (argCount <= 1)
        {
            [blockSignatureString appendFormat:@"(void)"];
        }
        else
        {
            NSMutableArray *argTypeNames = [[NSMutableArray alloc] initWithCapacity:(argCount - 1)];
            for (NSUInteger i = 1; i < argCount; ++i)
            {
                @autoreleasepool {
                    
                    NSString *argTypeName;
                    NSString *argDummyValueString;
                    [self
                     inspectValue:nil
                     objCType:[blockSignature getArgumentTypeAtIndex:i]
                     indentLevel:indentLevel
                     typeName:&argTypeName
                     valueString:&argDummyValueString];
                    [argTypeNames addObject:argTypeName];
                    
                }
            }
            [blockSignatureString appendFormat:@"(%@)", [argTypeNames componentsJoinedByString:@", "]];
        }
    }
    
    (*valueString) = [NSString stringWithFormat:@"<%p>%@", block, blockSignatureString];
}

+ (void)inspectNSError:(NSError *)error
           indentLevel:(NSUInteger)indentLevel
           valueString:(NSString *__autoreleasing *)valueString
{
    (*valueString) = [NSString stringWithFormat:
                      @"<%p> %@",
                      error,
                      [self
                       indentString:[[error userInfo] description]
                       withLevel:indentLevel]];
}

+ (void)inspectNSValue:(NSValue *)value
           indentLevel:(NSUInteger)indentLevel
           valueString:(NSString *__autoreleasing *)valueString
{
    NSString *valueTypeName;
    NSString *valueValueString;
    [self
     inspectValue:value
     objCType:[value objCType]
     indentLevel:indentLevel
     typeName:&valueTypeName
     valueString:&valueValueString];
    
    (*valueString) = [NSString stringWithFormat:@"<%p> (%@) %@", value, valueTypeName, valueValueString];
}

#pragma mark NSValue handlers

+ (void)inspectIdValue:(NSValue *)wrappedValue
              objCType:(const char *)objCType
           indentLevel:(NSUInteger)indentLevel
              typeName:(NSString *__autoreleasing *)typeName
           valueString:(NSString *__autoreleasing *)valueString
{
    id __unsafe_unretained idValue = nil;
    [wrappedValue getValue:&idValue];
    (*typeName) = (idValue
                   ? [NSString stringWithFormat:@"%@ *", [idValue class]]
                   : @"id");
    if (!idValue)
    {
        (*valueString) = @"nil";
    }
    else if ((strlen(objCType) > 1) && (objCType[1] == _C_UNDEF))
    {
        [self inspectNSBlock:idValue
                 indentLevel:indentLevel
                 valueString:valueString];
    }
    else if ([idValue isKindOfClass:[NSError class]])
    {
        [self inspectNSError:idValue
                 indentLevel:indentLevel
                 valueString:valueString];
    }
    else if ([idValue isKindOfClass:[NSValue class]])
    {
        [self inspectNSValue:idValue
                 indentLevel:indentLevel
                 valueString:valueString];
    }
    else
    {
        (*valueString) = [self
                          indentString:[idValue description]
                          withLevel:indentLevel];
    }
}

+ (void)inspectClassValue:(NSValue *)wrappedValue
                 typeName:(NSString *__autoreleasing *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    Class classValue = Nil;
    [wrappedValue getValue:&classValue];
    (*typeName) = @"Class";
    (*valueString) = (NSStringFromClass(classValue) ?: @"Nil");
}

+ (void)inspectSelectorValue:(NSValue *)wrappedValue
                    typeName:(NSString *__autoreleasing *)typeName
                 valueString:(NSString *__autoreleasing *)valueString
{
    SEL selectorValue = NULL;
    [wrappedValue getValue:&selectorValue];
    (*typeName) = @"SEL";
    (*valueString) = (NSStringFromSelector(selectorValue) ?: @"NULL");
}

+ (void)inspectCharValue:(NSValue *)wrappedValue
                typeName:(NSString *__autoreleasing *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    char charValue = '\0';
    [wrappedValue getValue:&charValue];
    (*typeName) = @"char";
    (*valueString) = [NSString stringWithFormat:@"'%1$c' (%1$i)", charValue];
}

+ (void)inspectUnsignedCharValue:(NSValue *)wrappedValue
                        typeName:(NSString *__autoreleasing *)typeName
                     valueString:(NSString *__autoreleasing *)valueString
{
    unsigned char unsignedCharValue = 0;
    [wrappedValue getValue:&unsignedCharValue];
    (*typeName) = @"unsigned char";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(unsignedCharValue)];
}

+ (void)inspectShortValue:(NSValue *)wrappedValue
                 typeName:(NSString *__autoreleasing *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    short shortValue = 0;
    [wrappedValue getValue:&shortValue];
    (*typeName) = @"short";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(shortValue)];
}

+ (void)inspectUnsignedShortValue:(NSValue *)wrappedValue
                         typeName:(NSString *__autoreleasing *)typeName
                      valueString:(NSString *__autoreleasing *)valueString
{
    unsigned short unsignedShortValue = 0;
    [wrappedValue getValue:&unsignedShortValue];
    (*typeName) = @"unsigned short";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(unsignedShortValue)];
}

+ (void)inspectIntValue:(NSValue *)wrappedValue
               typeName:(NSString *__autoreleasing *)typeName
            valueString:(NSString *__autoreleasing *)valueString
{
    int intValue = 0;
    [wrappedValue getValue:&intValue];
    (*typeName) = @"int";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(intValue)];
}

+ (void)inspectUnsignedIntValue:(NSValue *)wrappedValue
                       typeName:(NSString *__autoreleasing *)typeName
                    valueString:(NSString *__autoreleasing *)valueString
{
    unsigned int unsignedIntValue = 0;
    [wrappedValue getValue:&unsignedIntValue];
    (*typeName) = @"unsigned int";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(unsignedIntValue)];
}

+ (void)inspectLongValue:(NSValue *)wrappedValue
                typeName:(NSString *__autoreleasing *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    long longValue = 0;
    [wrappedValue getValue:&longValue];
    (*typeName) = @"long";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(longValue)];
}

+ (void)inspectUnsignedLongValue:(NSValue *)wrappedValue
                        typeName:(NSString *__autoreleasing *)typeName
                     valueString:(NSString *__autoreleasing *)valueString
{
    unsigned long unsignedLongValue = 0;
    [wrappedValue getValue:&unsignedLongValue];
    (*typeName) = @"unsigned long";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(unsignedLongValue)];
}

+ (void)inspectLongLongValue:(NSValue *)wrappedValue
                    typeName:(NSString *__autoreleasing *)typeName
                 valueString:(NSString *__autoreleasing *)valueString
{
    long long longlongValue = 0;
    [wrappedValue getValue:&longlongValue];
    (*typeName) = @"long long";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(longlongValue)];
}

+ (void)inspectUnsignedLongLongValue:(NSValue *)wrappedValue
                            typeName:(NSString *__autoreleasing *)typeName
                         valueString:(NSString *__autoreleasing *)valueString
{
    unsigned long long unsignedLonglongValue = 0;
    [wrappedValue getValue:&unsignedLonglongValue];
    (*typeName) = @"unsigned long long";
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(unsignedLonglongValue)];
}

+ (void)inspectFloatValue:(NSValue *)wrappedValue
                 typeName:(NSString *__autoreleasing *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    float floatValue = 0.0f;
    [wrappedValue getValue:&floatValue];
    (*typeName) = @"float";
    (*valueString) = [[self defaultDoubleFormatter] stringFromNumber:[[NSDecimalNumber alloc] initWithFloat:floatValue]];
}

+ (void)inspectDoubleValue:(NSValue *)wrappedValue
                  typeName:(NSString *__autoreleasing *)typeName
               valueString:(NSString *__autoreleasing *)valueString
{
    double doubleValue = 0.0;
    [wrappedValue getValue:&doubleValue];
    (*typeName) = @"double";
    (*valueString) = [[self defaultDoubleFormatter] stringFromNumber:[[NSDecimalNumber alloc] initWithDouble:doubleValue]];
}

+ (void)inspectBitFieldValue:(NSValue *)wrappedValue
                    objCType:(const char *)objCType
                    typeName:(NSString *__autoreleasing *)typeName
                 valueString:(NSString *__autoreleasing *)valueString
{
    // https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Conceptual/Archiving/Articles/codingctypes.html
    unsigned long long bitFieldValue = 0;
    [wrappedValue getValue:&bitFieldValue];
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:(objCType + 1)]];
    
    unsigned long long bitCount = 0;
    [scanner scanUnsignedLongLong:&bitCount];
    
    const unsigned long long shiftCount = (sizeof(bitFieldValue) - bitCount);
    bitFieldValue = ((bitFieldValue << shiftCount) >> shiftCount);
    
    (*typeName) = [NSString stringWithFormat:@"%llubit", bitCount];
    (*valueString) = [[self defaultIntegerFormatter] stringFromNumber:@(bitFieldValue)];
}

+ (void)inspectBoolValue:(NSValue *)wrappedValue
                typeName:(NSString *__autoreleasing *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    bool boolValue = false;
    [wrappedValue getValue:&boolValue];
    (*typeName) = @"bool";
    (*valueString) = (boolValue ? @"true" : @"false");
}

+ (void)inspectVoidValue:(NSValue *)wrappedValue
                typeName:(NSString *__autoreleasing *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    (*typeName) = @"void";
    (*valueString) = @"";
}

+ (void)inspectUndefinedValue:(NSValue *)wrappedValue
                     typeName:(NSString *__autoreleasing *)typeName
                  valueString:(NSString *__autoreleasing *)valueString
{
    (*typeName) = @"?";
    (*valueString) = @"";
}

+ (void)inspectPointerValue:(NSValue *)wrappedValue
                   objCType:(const char *)objCType
                indentLevel:(NSUInteger)indentLevel
                   typeName:(NSString *__autoreleasing *)typeName
                valueString:(NSString *__autoreleasing *)valueString
{
    const void *pointerValue = NULL;
    [wrappedValue getValue:&pointerValue];
    
    NSString *referencedTypeName;
    NSString *referencedValueString;
    
    objCType = [self objCTypeByIgnoringModifiers:(objCType + 1)];
    if (objCType[0] == _C_UNDEF)
    {
        referencedTypeName = @"func";
        referencedValueString = @"";
    }
    else
    {
        NSValue *referencedValue = (pointerValue
                                    ? [[NSValue alloc] initWithBytes:pointerValue objCType:objCType]
                                    : nil);
        [self
         inspectValue:referencedValue
         objCType:objCType
         indentLevel:indentLevel
         typeName:&referencedTypeName
         valueString:&referencedValueString];
    }
    
    (*typeName) = ([referencedTypeName hasSuffix:@"*"]
                   ? [referencedTypeName stringByAppendingString:@"*"]
                   : [referencedTypeName stringByAppendingString:@" *"]);
    (*valueString) = (pointerValue
                      ? [NSString stringWithFormat:@"<%p> %@", pointerValue, referencedValueString]
                      : @"NULL");
}

+ (void)inspectCStringValue:(NSValue *)wrappedValue
                   typeName:(NSString *__autoreleasing *)typeName
                valueString:(NSString *__autoreleasing *)valueString
{
    const char *cstringValue = NULL;
    [wrappedValue getValue:&cstringValue];
    (*typeName) = @"char *";
    (*valueString) = (cstringValue
                      ? [NSString stringWithFormat:@"<%1$p> \"%1$s\"", cstringValue]
                      : @"NULL");
}

+ (void)inspectAtomValue:(NSValue *)wrappedValue
                typeName:(NSString *__autoreleasing *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    (*typeName) = @"atom";
    (*valueString) = @"";
}

+ (void)inspectArrayValue:(NSValue *)wrappedValue
                 objCType:(const char *)objCType
              indentLevel:(NSUInteger)indentLevel
                 typeName:(NSString *__autoreleasing *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    NSUInteger arraySize = 0;
    NSUInteger arrayAlignedSize = 0;
    NSGetSizeAndAlignment(objCType, &arraySize, &arrayAlignedSize);
    
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
    unsigned long long sizePerSubelement = (arraySize / count);
    
    void *arrayValue = calloc((size_t)count, (size_t)sizePerSubelement);
    [wrappedValue getValue:arrayValue];
    
    NSMutableString *arrayValueString = [[NSMutableString alloc] init];
    NSString *indentString = [self indentStringWithLevel:indentLevel];
    for (unsigned long long i = 0; i < count; ++i)
    {
        if (i == 0)
        {
            [arrayValueString appendString:@"\n"];
            [arrayValueString appendString:indentString];
        }
        
        NSValue *itemValue = [[NSValue alloc]
                              initWithBytes:(arrayValue + (i * sizePerSubelement))
                              objCType:objCSubType];
        
        @autoreleasepool {
            
            NSString *itemTypeName;
            NSString *itemValueString;
            [self
             inspectValue:itemValue
             objCType:objCSubType
             indentLevel:(indentLevel + 1)
             typeName:&itemTypeName
             valueString:&itemValueString];
            
            [arrayValueString appendFormat:@"\t[%llu]: (%@) %@,\n", i, itemTypeName, itemValueString];
            
        }
        
        [arrayValueString appendString:indentString];
    }
    
    NSString *itemTypeName;
    NSString *itemValueString;
    [self
     inspectValue:nil
     objCType:objCSubType
     indentLevel:(indentLevel + 1)
     typeName:&itemTypeName
     valueString:&itemValueString];
    
    (*typeName) = [NSString stringWithFormat:@"%@[%llu]", itemTypeName, count];
    (*valueString) = [NSString stringWithFormat:@"[%@]", arrayValueString];
    
    free(arrayValue);
}

+ (void)inspectUnionValue:(NSValue *)wrappedValue
                 objCType:(const char *)objCType
              indentLevel:(NSUInteger)indentLevel
                 typeName:(NSString *__autoreleasing *)typeName
              valueString:(NSString *__autoreleasing *)valueString JE_NONNULL(2,4,5)
{
    NSUInteger unionSize = 0;
    NSUInteger unionAlignedSize = 0;
    NSGetSizeAndAlignment(objCType, &unionSize, &unionAlignedSize);
    
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_UNION_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    NSString *subtype;
    [scanner scanUpToString:@"\0" intoString:&subtype];
    
    NSString *unionString;
    if (wrappedValue)
    {
        unionString = [NSString stringWithFormat:@"{ %@ }", [wrappedValue debugDescription]];
    }
    else
    {
        unionString = @"{ ... }"; // NSValue cannot handle bitfields
    }
    
    (*typeName) = [NSString stringWithFormat:@"struct %@", structName];
    (*valueString) = unionString;
}

+ (void)inspectStructValue:(NSValue *)wrappedValue
                  objCType:(const char *)objCType
               indentLevel:(NSUInteger)indentLevel
                  typeName:(NSString *__autoreleasing *)typeName
               valueString:(NSString *__autoreleasing *)valueString JE_NONNULL(2,4,5)
{
    NSUInteger structSize = 0;
    NSUInteger structAlignedSize = 0;
    NSGetSizeAndAlignment(objCType, &structSize, &structAlignedSize);
    
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_STRUCT_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    NSString *subtype;
    [scanner scanUpToString:@"\0" intoString:&subtype];
    
    NSString *structString;
    if ([structName hasPrefix:@"CG"])
    {
        if ([structName isEqualToString:@"CGPoint"])
        {
            structString = NSStringFromCGPoint([wrappedValue CGPointValue]);
        }
        else if ([structName isEqualToString:@"CGSize"])
        {
            structString = NSStringFromCGSize([wrappedValue CGSizeValue]);
        }
        else if ([structName isEqualToString:@"CGRect"])
        {
            structString = NSStringFromCGRect([wrappedValue CGRectValue]);
        }
        else if ([structName isEqualToString:@"CGAffineTransform"])
        {
            structString = NSStringFromCGAffineTransform([wrappedValue CGAffineTransformValue]);
        }
    }
    else if ([structName hasPrefix:@"UI"])
    {
        if ([structName isEqualToString:@"UIEdgeInsets"])
        {
            structString = NSStringFromUIEdgeInsets([wrappedValue UIEdgeInsetsValue]);
        }
        else if ([structName isEqualToString:@"UIOffset"])
        {
            structString = NSStringFromUIOffset([wrappedValue UIOffsetValue]);
        }
    }
    else if ([structName isEqualToString:@"_NSRange"])
    {
        structString = NSStringFromRange([wrappedValue rangeValue]);
    }
    
    if (!structString)
    {
        if (wrappedValue)
        {
            structString = [NSString stringWithFormat:@"{ %@ }", [wrappedValue debugDescription]];
        }
        else
        {
            structString = @"{ ... }"; // NSValue cannot handle bitfields
        }
    }
    
    (*typeName) = [NSString stringWithFormat:@"struct %@", structName];
    (*valueString) = structString;
}

+ (void)inspectValue:(NSValue *)wrappedValue
            objCType:(const char *)objCType
         indentLevel:(NSUInteger)indentLevel
            typeName:(NSString *__autoreleasing *)typeName
         valueString:(NSString *__autoreleasing *)valueString JE_NONNULL(2,4,5)
{
    if (!objCType)
    {
        [self
         inspectUndefinedValue:wrappedValue
         typeName:typeName
         valueString:valueString];
        return;
    }
    
    objCType = [self objCTypeByIgnoringModifiers:objCType];
    switch (objCType[0])
    {
        case _C_ID:
            [self
             inspectIdValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_CLASS:
            [self
             inspectClassValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_SEL:
            [self
             inspectSelectorValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_CHR:
            [self
             inspectCharValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_UCHR:
            [self
             inspectUnsignedCharValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_SHT:
            [self
             inspectShortValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_USHT:
            [self
             inspectUnsignedShortValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_INT:
            [self
             inspectIntValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_UINT:
            [self
             inspectUnsignedIntValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_LNG:
            [self
             inspectLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_ULNG:
            [self
             inspectUnsignedLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_LNG_LNG:
            [self
             inspectLongLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_ULNG_LNG:
            [self
             inspectUnsignedLongLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_FLT:
            [self
             inspectFloatValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_DBL:
            [self
             inspectDoubleValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_BFLD:
            [self
             inspectBitFieldValue:wrappedValue
             objCType:objCType
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_BOOL:
            [self
             inspectBoolValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_VOID:
            [self
             inspectVoidValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_PTR:
            [self
             inspectPointerValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_CHARPTR:
            [self
             inspectCStringValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_ARY_B:
            [self
             inspectArrayValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_UNION_B:
            [self
             inspectUnionValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_STRUCT_B:
            [self
             inspectStructValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_UNDEF:
        case _C_ATOM:
        case _C_VECTOR:
        default:
            [self
             inspectUndefinedValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
    }
}


#pragma mark - public

+ (void)logValue:(NSValue *)wrappedValue
      sourceFile:(const char *)sourceFile
    functionName:(const char *)functionName
      lineNumber:(NSInteger)lineNumber
           label:(const char *)label
{
    @autoreleasepool {
        
        NSString *typeName;
        NSString *valueString;
        
        [self
         inspectValue:wrappedValue
         objCType:[wrappedValue objCType]
         indentLevel:0
         typeName:&typeName
         valueString:&valueString];
        
        NSString *consoleString = [[NSString alloc] initWithFormat:
                                   @"[%s] %s:%ld %s\n→\t\"%s\"\n\t→\t(%@) %@\n",
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                                   dispatch_queue_get_label(dispatch_get_current_queue()),
#pragma clang diagnostic pop
                                   ((strrchr(sourceFile, '/') ?: (sourceFile - 1)) + 1),
                                   (long)lineNumber,
                                   functionName,
                                   label,
                                   typeName,
                                   valueString];
        
        dispatch_barrier_sync([self barrierQueue], ^{
            
            puts([consoleString UTF8String]);
            
        });
        
    }
}

+ (void)logFormat:(NSString *)format
       sourceFile:(const char *)sourceFile
     functionName:(const char *)functionName
       lineNumber:(NSInteger)lineNumber, ...
{
    va_list arguments;
    va_start(arguments, lineNumber);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
	va_end(arguments);
    
    NSString *consoleString = [[NSString alloc] initWithFormat:
                               @"[%s] %s:%ld %s\n→\t\%@\n",
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                               dispatch_queue_get_label(dispatch_get_current_queue()),
#pragma clang diagnostic pop
                               ((strrchr(sourceFile, '/') ?: (sourceFile - 1)) + 1),
                               (long)lineNumber,
                               functionName,
                               formattedString];
    
    dispatch_barrier_sync([self barrierQueue], ^{
        
        puts([consoleString UTF8String]);
        
    });
}


@end

