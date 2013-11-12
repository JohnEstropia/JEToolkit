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

+ (const char *)objCTypeByIgnoringModifiers:(const char *)objCType
{
    // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
    
    while (objCType != NULL && objCType[0] != '\0')
    {
        const char typeModifier = objCType[0];
        if (typeModifier != 'r' // const
            && typeModifier != 'n' // in
            && typeModifier != 'N' // inout
            && typeModifier != 'o' // out
            && typeModifier != 'O' // bycopy
            && typeModifier != 'R' // byref
            && typeModifier != 'V') // oneway
        {
            break;
        }
        objCType++;
    }
    return objCType;
}

+ (NSNumberFormatter *)integerFormatter
{
	static NSNumberFormatter *integerFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		integerFormatter = [[NSNumberFormatter alloc] init];
		[integerFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
		
	});
	return integerFormatter;
}

+ (NSNumberFormatter *)scientificFormatter
{
	static NSNumberFormatter *scientificFormatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		scientificFormatter = [[NSNumberFormatter alloc] init];
		[scientificFormatter setNumberStyle:NSNumberFormatterScientificStyle];
		
	});
	return scientificFormatter;
}

+ (void)logStringFromIdValue:(NSValue *)wrappedValue
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
    else if ([idValue isKindOfClass:[NSError class]])
    {
        (*valueString) = [NSString stringWithFormat:@"%@", [(NSError *)idValue userInfo]];
    }
    else
    {
        (*valueString) = [NSString stringWithFormat:@"%@", [idValue description]];
    }
}

+ (void)logStringFromClassValue:(NSValue *)wrappedValue
                       typeName:(NSString *__autoreleasing *)typeName
                    valueString:(NSString *__autoreleasing *)valueString
{
    Class classValue = Nil;
    [wrappedValue getValue:&classValue];
    (*typeName) = @"Class";
    (*valueString) = (NSStringFromClass(classValue) ?: @"Nil");
}

+ (void)logStringFromSelectorValue:(NSValue *)wrappedValue
                          typeName:(NSString *__autoreleasing *)typeName
                       valueString:(NSString *__autoreleasing *)valueString
{
    SEL selectorValue = NULL;
    [wrappedValue getValue:&selectorValue];
    (*typeName) = @"SEL";
    (*valueString) = (NSStringFromSelector(selectorValue) ?: @"NULL");
}

+ (void)logStringFromCharValue:(NSValue *)wrappedValue
                      typeName:(NSString *__autoreleasing *)typeName
                   valueString:(NSString *__autoreleasing *)valueString
{
    char charValue = '\0';
    [wrappedValue getValue:&charValue];
    (*typeName) = @"char";
    (*valueString) = [NSString stringWithFormat:@"'%1$c' (%1$i)", charValue];
}

+ (void)logStringFromUnsignedCharValue:(NSValue *)wrappedValue
                              typeName:(NSString *__autoreleasing *)typeName
                           valueString:(NSString *__autoreleasing *)valueString
{
    unsigned char unsignedCharValue = 0;
    [wrappedValue getValue:&unsignedCharValue];
    (*typeName) = @"unsigned char";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedCharValue)];
}

+ (void)logStringFromShortValue:(NSValue *)wrappedValue
                       typeName:(NSString *__autoreleasing *)typeName
                    valueString:(NSString *__autoreleasing *)valueString
{
    short shortValue = 0;
    [wrappedValue getValue:&shortValue];
    (*typeName) = @"short";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(shortValue)];
}

+ (void)logStringFromUnsignedShortValue:(NSValue *)wrappedValue
                               typeName:(NSString *__autoreleasing *)typeName
                            valueString:(NSString *__autoreleasing *)valueString
{
    unsigned short unsignedShortValue = 0;
    [wrappedValue getValue:&unsignedShortValue];
    (*typeName) = @"unsigned short";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedShortValue)];
}

+ (void)logStringFromIntValue:(NSValue *)wrappedValue
                     typeName:(NSString *__autoreleasing *)typeName
                  valueString:(NSString *__autoreleasing *)valueString
{
    int intValue = 0;
    [wrappedValue getValue:&intValue];
    (*typeName) = @"int";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(intValue)];
}

+ (void)logStringFromUnsignedIntValue:(NSValue *)wrappedValue
                             typeName:(NSString *__autoreleasing *)typeName
                          valueString:(NSString *__autoreleasing *)valueString
{
    unsigned int unsignedIntValue = 0;
    [wrappedValue getValue:&unsignedIntValue];
    (*typeName) = @"unsigned int";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedIntValue)];
}

+ (void)logStringFromLongValue:(NSValue *)wrappedValue
                      typeName:(NSString *__autoreleasing *)typeName
                   valueString:(NSString *__autoreleasing *)valueString
{
    long longValue = 0;
    [wrappedValue getValue:&longValue];
    (*typeName) = @"long";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(longValue)];
}

+ (void)logStringFromUnsignedLongValue:(NSValue *)wrappedValue
                              typeName:(NSString *__autoreleasing *)typeName
                           valueString:(NSString *__autoreleasing *)valueString
{
    unsigned long unsignedLongValue = 0;
    [wrappedValue getValue:&unsignedLongValue];
    (*typeName) = @"unsigned long";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedLongValue)];
}

+ (void)logStringFromLongLongValue:(NSValue *)wrappedValue
                          typeName:(NSString *__autoreleasing *)typeName
                       valueString:(NSString *__autoreleasing *)valueString
{
    long long longlongValue = 0;
    [wrappedValue getValue:&longlongValue];
    (*typeName) = @"long long";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(longlongValue)];
}

+ (void)logStringFromUnsignedLongLongValue:(NSValue *)wrappedValue
                                  typeName:(NSString *__autoreleasing *)typeName
                               valueString:(NSString *__autoreleasing *)valueString
{
    unsigned long long unsignedLonglongValue = 0;
    [wrappedValue getValue:&unsignedLonglongValue];
    (*typeName) = @"unsigned long long";
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedLonglongValue)];
}

+ (void)logStringFromFloatValue:(NSValue *)wrappedValue
                       typeName:(NSString *__autoreleasing *)typeName
                    valueString:(NSString *__autoreleasing *)valueString
{
    float floatValue = 0.0f;
    [wrappedValue getValue:&floatValue];
    (*typeName) = @"float";
    (*valueString) = [[self scientificFormatter] stringFromNumber:[[NSDecimalNumber alloc] initWithFloat:floatValue]];
}

+ (void)logStringFromDoubleValue:(NSValue *)wrappedValue
                        typeName:(NSString *__autoreleasing *)typeName
                     valueString:(NSString *__autoreleasing *)valueString
{
    double doubleValue = 0.0;
    [wrappedValue getValue:&doubleValue];
    (*typeName) = @"double";
    (*valueString) = [[self scientificFormatter] stringFromNumber:[[NSDecimalNumber alloc] initWithDouble:doubleValue]];
}

+ (void)logStringFromBitFieldValue:(NSValue *)wrappedValue
                          objCType:(const char *)objCType
                          typeName:(NSString *__autoreleasing *)typeName
                       valueString:(NSString *__autoreleasing *)valueString
{
#warning TODO: NSValue cannot be created from struct containing bitfields
    unsigned long long bitFieldValue = 0;
    [wrappedValue getValue:&bitFieldValue];
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:(objCType + 1)]];
    
    unsigned long long bitCount = 0;
    [scanner scanUnsignedLongLong:&bitCount];
    
    const unsigned long long shiftCount = (sizeof(bitFieldValue) - bitCount);
    bitFieldValue = ((bitFieldValue << shiftCount) >> shiftCount);
    
    (*typeName) = [NSString stringWithFormat:@"%llubit", bitCount];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(bitFieldValue)];
}

+ (void)logStringFromBoolValue:(NSValue *)wrappedValue
                      typeName:(NSString *__autoreleasing *)typeName
                   valueString:(NSString *__autoreleasing *)valueString
{
    bool boolValue = false;
    [wrappedValue getValue:&boolValue];
    (*typeName) = @"bool";
    (*valueString) = (boolValue ? @"true" : @"false");
}

+ (void)logStringFromVoidValue:(NSValue *)wrappedValue
                      typeName:(NSString *__autoreleasing *)typeName
                   valueString:(NSString *__autoreleasing *)valueString
{
    (*typeName) = @"void";
    (*valueString) = @"";
}

+ (void)logStringFromUndefinedValue:(NSValue *)wrappedValue
                           typeName:(NSString *__autoreleasing *)typeName
                        valueString:(NSString *__autoreleasing *)valueString
{
    (*typeName) = @"?";
    (*valueString) = @"";
}

+ (void)logStringFromPointerValue:(NSValue *)wrappedValue
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
         logStringFromValue:referencedValue
         objCType:objCType
         indentLevel:(indentLevel + 1)
         typeName:&referencedTypeName
         valueString:&referencedValueString];
    }
    
    (*typeName) = [NSString stringWithFormat:@"%1$@ *", referencedTypeName];
    (*valueString) = (pointerValue
                      ? [NSString stringWithFormat:@"<%p>", pointerValue]
                      : @"NULL");
}

+ (void)logStringFromCStringValue:(NSValue *)wrappedValue
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

+ (void)logStringFromAtomValue:(NSValue *)wrappedValue
                      typeName:(NSString *__autoreleasing *)typeName
                   valueString:(NSString *__autoreleasing *)valueString
{
    (*typeName) = @"atom";
    (*valueString) = @"";
}

+ (void)logStringFromArrayValue:(NSValue *)wrappedValue
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
    for (unsigned long long i = 0; i < count; ++i)
    {
        if (i == 0)
        {
            [arrayValueString appendString:@"\n"];
            
            for (NSUInteger indent = 0; indent <= indentLevel; ++indent)
            {
                [arrayValueString appendString:@"\t"];
            }
        }
        
        NSValue *itemValue = [[NSValue alloc]
                              initWithBytes:(arrayValue + (i * sizePerSubelement))
                              objCType:objCSubType];
        NSString *itemTypeName;
        NSString *itemValueString;
        [self
         logStringFromValue:itemValue
         objCType:objCSubType
         indentLevel:(indentLevel + 1)
         typeName:&itemTypeName
         valueString:&itemValueString];
        
        [arrayValueString appendFormat:@"\t[%llu]: (%@) %@,\n", i, itemTypeName, itemValueString];
        
        for (NSUInteger indent = 0; indent <= indentLevel; ++indent)
        {
            [arrayValueString appendString:@"\t"];
        }
    }
    
    NSString *itemTypeName;
    NSString *itemValueString;
    [self
     logStringFromValue:nil
     objCType:objCSubType
     indentLevel:(indentLevel + 1)
     typeName:&itemTypeName
     valueString:&itemValueString];
    
    (*typeName) = [NSString stringWithFormat:@"%@[%llu]", itemTypeName, count];
    (*valueString) = [NSString stringWithFormat:@"[%@]", arrayValueString];
    
    free(arrayValue);
}

+ (void)logStringFromUnionValue:(NSValue *)wrappedValue
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

+ (void)logStringFromStructValue:(NSValue *)wrappedValue
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

+ (void)logStringFromValue:(NSValue *)wrappedValue
                  objCType:(const char *)objCType
               indentLevel:(NSUInteger)indentLevel
                  typeName:(NSString *__autoreleasing *)typeName
               valueString:(NSString *__autoreleasing *)valueString JE_NONNULL(2,4,5)
{
    if (!objCType)
    {
        [self
         logStringFromUndefinedValue:wrappedValue
         typeName:typeName
         valueString:valueString];
        return;
    }
    
    objCType = [self objCTypeByIgnoringModifiers:objCType];
    switch (objCType[0])
    {
        case _C_ID:
            [self
             logStringFromIdValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_CLASS:
            [self
             logStringFromClassValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_SEL:
            [self
             logStringFromSelectorValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_CHR:
            [self
             logStringFromCharValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_UCHR:
            [self
             logStringFromUnsignedCharValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_SHT:
            [self
             logStringFromShortValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_USHT:
            [self
             logStringFromUnsignedShortValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_INT:
            [self
             logStringFromIntValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_UINT:
            [self
             logStringFromUnsignedIntValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_LNG:
            [self
             logStringFromLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_ULNG:
            [self
             logStringFromUnsignedLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_LNG_LNG:
            [self
             logStringFromLongLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_ULNG_LNG:
            [self
             logStringFromUnsignedLongLongValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_FLT:
            [self
             logStringFromFloatValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_DBL:
            [self
             logStringFromDoubleValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_BFLD:
            [self
             logStringFromBitFieldValue:wrappedValue
             objCType:objCType
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_BOOL:
            [self
             logStringFromBoolValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_VOID:
            [self
             logStringFromVoidValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_PTR:
            [self
             logStringFromPointerValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_CHARPTR:
            [self
             logStringFromCStringValue:wrappedValue
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_ARY_B:
            [self
             logStringFromArrayValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_UNION_B:
            [self
             logStringFromUnionValue:wrappedValue
             objCType:objCType
             indentLevel:indentLevel
             typeName:typeName
             valueString:valueString];
            break;
            
        case _C_STRUCT_B:
            [self
             logStringFromStructValue:wrappedValue
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
             logStringFromUndefinedValue:wrappedValue
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
        
        [self logStringFromValue:wrappedValue
                        objCType:[wrappedValue objCType]
                     indentLevel:0
                        typeName:&typeName
                     valueString:&valueString];
        
        printf("[%s](%s:%ld) %s\n>\t\"%s\" = (%s) %s\n\n",
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
               dispatch_queue_get_label(dispatch_get_current_queue()),
#pragma clang diagnostic pop
               ((strrchr(sourceFile, '/') ?: sourceFile - 1) + 1),
               (long)lineNumber,
               functionName,
               label,
               [typeName UTF8String],
               [valueString UTF8String]);
    }
}

+ (void)logFormat:(NSString *)format
       sourceFile:(const char *)sourceFile
     functionName:(const char *)functionName
       lineNumber:(NSInteger)lineNumber, ...
{
    va_list arguments;
    va_start(arguments, lineNumber);
    
    printf("[%s](%s:%ld) %s\n>\t\%s\n",
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
           dispatch_queue_get_label(dispatch_get_current_queue()),
#pragma clang diagnostic pop
           ((strrchr(sourceFile, '/') ?: sourceFile - 1) + 1),
           (long)lineNumber,
           functionName,
           [[[NSString alloc] initWithFormat:format arguments:arguments] UTF8String]);
    
	va_end(arguments);
}

@end

