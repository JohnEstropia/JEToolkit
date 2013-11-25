//
//  JEDebugging.m
//  JEToolkit
//
//  Created by John Rommel Estropia on 2013/09/28.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import "JEDebugging.h"

#import <objc/runtime.h>

#import "JESafetyHelpers.h"
#import "NSString+JEToolkit.h"
#import "NSCalendar+JEToolkit.h"


@interface NSObject (_JEDebugging)

- (NSMutableString *)_JE_escapedDescription;
- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress;

@end


@interface JEDebugging ()

@property (nonatomic, assign) JEConsoleLogHeaderMask consoleLogHeaderMask;
@property (nonatomic, assign) JEConsoleLogHeaderMask HUDLogHeaderMask;
@property (nonatomic, copy) NSString *logBulletString;
@property (nonatomic, copy) NSString *dumpBulletString;

@end


@implementation JEDebugging

#pragma mark - NSObject

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    
    _consoleLogHeaderMask = JEConsoleLogHeaderMaskDefault;
    _HUDLogHeaderMask = JEConsoleLogHeaderMaskDefault;
    _logBulletString = nil;
    _dumpBulletString = nil;
    
    
    return self;
}


#pragma mark - private

#pragma mark Shared Objects

+ (JEDebugging *)sharedInstance
{
    static JEDebugging *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[JEDebugging alloc] init];
        
    });
    return sharedInstance;
}

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

+ (NSDateFormatter *)consoleDateFormatter
{
    static NSDateFormatter *consoleDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [formatter setCalendar:[NSCalendar gregorianCalendar]];
        [formatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss'.'SSS"];
        consoleDateFormatter = formatter;
        
    });
    return consoleDateFormatter;
}

+ (dispatch_queue_t)consoleQueue
{
    static dispatch_queue_t consoleQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        consoleQueue = dispatch_queue_create("JEDebugging.consoleQueue", DISPATCH_QUEUE_CONCURRENT);
        
    });
    return consoleQueue;
}

+ (dispatch_queue_t)settingsQueue
{
    static dispatch_queue_t settingsQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        settingsQueue = dispatch_queue_create("JEDebugging.settingsQueue", DISPATCH_QUEUE_CONCURRENT);
        
    });
    return settingsQueue;
}

+ (NSString *)defaultLogBulletString
{
    return @"🔹";
}

+ (NSString *)defaultDumpBulletString
{
    return @"🔸";
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

+ (NSString *)indentationWithLevel:(NSUInteger)indentLevel
{
    return [[NSString string]
            stringByPaddingToLength:(indentLevel + 2) * 2
            withString:@" "
            startingAtIndex:0];
}

+ (void)indentString:(NSMutableString *)string withLevel:(NSUInteger)indentLevel
{
    [string
     replaceOccurrencesOfString:@"\n"
     withString:[@"\n"
                 stringByPaddingToLength:(indentLevel + 2) * 2
                 withString:@" "
                 startingAtIndex:0]
     options:(NSCaseInsensitiveSearch | NSLiteralSearch)
     range:[string range]];
}

#pragma mark JEDump handlers

+ (void)inspectIdValue:(NSValue *)wrappedValue
              objCType:(const char *)objCType
           indentLevel:(NSUInteger)indentLevel
              typeName:(NSMutableString *)typeName
           valueString:(NSString *__autoreleasing *)valueString
{
    id __unsafe_unretained idValue = nil;
    [wrappedValue getValue:&idValue];
    
    if (idValue)
    {
        [typeName appendFormat:@"%@ *", [idValue class]];
    }
    else
    {
        [typeName appendString:@"id"];
    }
    
    if (!valueString)
    {
        return;
    }
    
    if (!idValue)
    {
        (*valueString) = @"nil";
    }
    else if ((strlen(objCType) > 1) && (objCType[1] == _C_UNDEF))
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
                
                [blockSignatureString appendString:@" "];
                [self
                 inspectValue:nil
                 objCType:[blockSignature methodReturnType]
                 indentLevel:0
                 typeName:blockSignatureString
                 valueString:NULL];
                [blockSignatureString appendString:@"(^)"];
                
            }
            
            NSUInteger argCount = [blockSignature numberOfArguments];
            if (argCount <= 1)
            {
                [blockSignatureString appendFormat:@"(void)"];
            }
            else
            {
                [blockSignatureString appendString:@"("];
                
                for (NSUInteger i = 1; i < argCount; ++i)
                {
                    @autoreleasepool {
                        
                        if (i > 1)
                        {
                            [blockSignatureString appendString:@","];
                        }
                    
                        [self
                         inspectValue:nil
                         objCType:[blockSignature getArgumentTypeAtIndex:i]
                         indentLevel:indentLevel
                         typeName:blockSignatureString
                         valueString:NULL];
                        
                    }
                }
                [blockSignatureString appendString:@")"];
            }
        }
        
        (*valueString) = [NSString stringWithFormat:@"<%p>%@", idValue, blockSignatureString];
    }
    else
    {
        (*valueString) = [idValue _JE_logStringWithIndentLevel:indentLevel includeAddress:YES];
    }
}

+ (void)inspectClassValue:(NSValue *)wrappedValue
                 typeName:(NSMutableString *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"Class"];
    
    if (!valueString)
    {
        return;
    }
    
    Class classValue = Nil;
    [wrappedValue getValue:&classValue];
    (*valueString) = (NSStringFromClass(classValue) ?: @"Nil");
}

+ (void)inspectSelectorValue:(NSValue *)wrappedValue
                    typeName:(NSMutableString *)typeName
                 valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"SEL"];
    
    if (!valueString)
    {
        return;
    }
    
    SEL selectorValue = NULL;
    [wrappedValue getValue:&selectorValue];
    (*valueString) = (NSStringFromSelector(selectorValue) ?: @"NULL");
}

+ (void)inspectCharValue:(NSValue *)wrappedValue
                typeName:(NSMutableString *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"char"];
    
    if (!valueString)
    {
        return;
    }
    
    char charValue = '\0';
    [wrappedValue getValue:&charValue];
    (*valueString) = [NSString stringWithFormat:@"'%1$c' (%1$i)", charValue];
}

+ (void)inspectUnsignedCharValue:(NSValue *)wrappedValue
                        typeName:(NSMutableString *)typeName
                     valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"unsigned char"];
    
    if (!valueString)
    {
        return;
    }
    
    unsigned char unsignedCharValue = 0;
    [wrappedValue getValue:&unsignedCharValue];
    (*valueString) = [NSString stringWithFormat:@"%uc", unsignedCharValue];
}

+ (void)inspectShortValue:(NSValue *)wrappedValue
                 typeName:(NSMutableString *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"short"];
    
    if (!valueString)
    {
        return;
    }
    
    short shortValue = 0;
    [wrappedValue getValue:&shortValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(shortValue)];
}

+ (void)inspectUnsignedShortValue:(NSValue *)wrappedValue
                         typeName:(NSMutableString *)typeName
                      valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"unsigned short"];
    
    if (!valueString)
    {
        return;
    }
    
    unsigned short unsignedShortValue = 0;
    [wrappedValue getValue:&unsignedShortValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedShortValue)];
}

+ (void)inspectIntValue:(NSValue *)wrappedValue
               typeName:(NSMutableString *)typeName
            valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"int"];
    
    if (!valueString)
    {
        return;
    }
    
    int intValue = 0;
    [wrappedValue getValue:&intValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(intValue)];
}

+ (void)inspectUnsignedIntValue:(NSValue *)wrappedValue
                       typeName:(NSMutableString *)typeName
                    valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"unsigned int"];
    
    if (!valueString)
    {
        return;
    }
    
    unsigned int unsignedIntValue = 0;
    [wrappedValue getValue:&unsignedIntValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedIntValue)];
}

+ (void)inspectLongValue:(NSValue *)wrappedValue
                typeName:(NSMutableString *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"long"];
    
    if (!valueString)
    {
        return;
    }
    
    long longValue = 0;
    [wrappedValue getValue:&longValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(longValue)];
}

+ (void)inspectUnsignedLongValue:(NSValue *)wrappedValue
                        typeName:(NSMutableString *)typeName
                     valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"unsigned long"];
    
    if (!valueString)
    {
        return;
    }
    
    unsigned long unsignedLongValue = 0;
    [wrappedValue getValue:&unsignedLongValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedLongValue)];
}

+ (void)inspectLongLongValue:(NSValue *)wrappedValue
                    typeName:(NSMutableString *)typeName
                 valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"long long"];
    
    if (!valueString)
    {
        return;
    }
    
    long long longlongValue = 0;
    [wrappedValue getValue:&longlongValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(longlongValue)];
}

+ (void)inspectUnsignedLongLongValue:(NSValue *)wrappedValue
                            typeName:(NSMutableString *)typeName
                         valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"unsigned long long"];
    
    if (!valueString)
    {
        return;
    }
    
    unsigned long long unsignedLonglongValue = 0;
    [wrappedValue getValue:&unsignedLonglongValue];
    (*valueString) = [[self integerFormatter] stringFromNumber:@(unsignedLonglongValue)];
}

+ (void)inspectFloatValue:(NSValue *)wrappedValue
                 typeName:(NSMutableString *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"float"];
    
    if (!valueString)
    {
        return;
    }
    
    float floatValue = 0.0f;
    [wrappedValue getValue:&floatValue];
    
    static const NSInteger _JREDecimalDigits = 9;
    
    (*valueString) = (floatValue >= (powf(10.0f, (_JREDecimalDigits - 1)))
                      ? [NSString stringWithFormat:@"%.*e", FLT_DIG, floatValue]
                      : [NSString stringWithFormat:@"%.*g", _JREDecimalDigits, floatValue]);
}

+ (void)inspectDoubleValue:(NSValue *)wrappedValue
                  typeName:(NSMutableString *)typeName
               valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"double"];
    
    if (!valueString)
    {
        return;
    }
    
    double doubleValue = 0.0;
    [wrappedValue getValue:&doubleValue];
    
    static const NSInteger _JREDecimalDigits = 17;
    
    (*valueString) = (doubleValue >= (pow(10.0, (_JREDecimalDigits - 1)))
                      ? [NSString stringWithFormat:@"%.*e", DBL_DIG, doubleValue]
                      : [NSString stringWithFormat:@"%.*g", _JREDecimalDigits, doubleValue]);
}

+ (void)inspectLongDoubleValue:(NSValue *)wrappedValue
                  typeName:(NSMutableString *)typeName
               valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"long double"];
    
    if (!valueString)
    {
        return;
    }
    
    long double longDoubleValue = 0.0l;
    [wrappedValue getValue:&longDoubleValue];
    
    static const NSInteger _JREDecimalDigits = 21;
    
    (*valueString) = (longDoubleValue >= (powl(10.0l, (_JREDecimalDigits - 1)))
                      ? [NSString stringWithFormat:@"%.*Le", LDBL_DIG, longDoubleValue]
                      : [NSString stringWithFormat:@"%.*Lg", _JREDecimalDigits, longDoubleValue]);
}

+ (void)inspectBitFieldValue:(NSValue *)wrappedValue
                    objCType:(const char *)objCType
                    typeName:(NSMutableString *)typeName
                 valueString:(NSString *__autoreleasing *)valueString
{
    NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:(objCType + 1)]];
    
    unsigned long long bitCount = 0;
    [scanner scanUnsignedLongLong:&bitCount];
    
    [typeName appendFormat:@"%llubit", bitCount];
    
    if (!valueString)
    {
        return;
    }
    
    // https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Conceptual/Archiving/Articles/codingctypes.html
    unsigned long long bitFieldValue = 0;
    [wrappedValue getValue:&bitFieldValue];
    
    const unsigned long long shiftCount = (sizeof(bitFieldValue) - bitCount);
    bitFieldValue = ((bitFieldValue << shiftCount) >> shiftCount);
    
    (*valueString) = [[self integerFormatter] stringFromNumber:@(bitFieldValue)];
}

+ (void)inspectBoolValue:(NSValue *)wrappedValue
                typeName:(NSMutableString *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"bool"];
    
    if (!valueString)
    {
        return;
    }
    
    bool boolValue = false;
    [wrappedValue getValue:&boolValue];
    (*valueString) = (boolValue ? @"true" : @"false");
}

+ (void)inspectVoidValue:(NSValue *)wrappedValue
                typeName:(NSMutableString *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"void"];
    
    if (!valueString)
    {
        return;
    }
    
    (*valueString) = @"";
}

+ (void)inspectUndefinedValue:(NSValue *)wrappedValue
                     typeName:(NSMutableString *)typeName
                  valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"?"];
    
    if (!valueString)
    {
        return;
    }
    
    (*valueString) = @"";
}

+ (void)inspectPointerValue:(NSValue *)wrappedValue
                   objCType:(const char *)objCType
                indentLevel:(NSUInteger)indentLevel
                   typeName:(NSMutableString *)typeName
                valueString:(NSString *__autoreleasing *)valueString
{
    const void *pointerValue = NULL;
    [wrappedValue getValue:&pointerValue];
    
    objCType = [self objCTypeByIgnoringModifiers:(objCType + 1)];
    if (objCType[0] == _C_UNDEF)
    {
        [typeName appendString:@"func *"];
        
        if (!valueString)
        {
            return;
        }
        
        (*valueString) = (pointerValue
                          ? [NSString stringWithFormat:@"<%p>", pointerValue]
                          : @"NULL");
    }
    else
    {
        NSString *referencedValueString;
        
        [self
         inspectValue:(pointerValue
                       ? [[NSValue alloc] initWithBytes:pointerValue objCType:objCType]
                       : nil)
         objCType:objCType
         indentLevel:indentLevel
         typeName:typeName
         valueString:(valueString
                      ? &referencedValueString
                      : NULL)];
        
        [typeName appendString:([typeName hasSuffix:@"*"]
                                ? @"*"
                                : @" *")];
        
        if (!valueString)
        {
            return;
        }
        
        (*valueString) = (pointerValue
                          ? [NSString stringWithFormat:@"<%p> %@", pointerValue, referencedValueString]
                          : @"NULL");
    }
}

+ (void)inspectCStringValue:(NSValue *)wrappedValue
                   typeName:(NSMutableString *)typeName
                valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"char *"];
    
    if (!valueString)
    {
        return;
    }
    
    const char *cstringValue = NULL;
    [wrappedValue getValue:&cstringValue];
    (*valueString) = (cstringValue
                      ? [NSString stringWithFormat:@"<%1$p> \"%1$s\"", cstringValue]
                      : @"NULL");
}

+ (void)inspectAtomValue:(NSValue *)wrappedValue
                typeName:(NSMutableString *)typeName
             valueString:(NSString *__autoreleasing *)valueString
{
    [typeName appendString:@"atom"];
    
    if (!valueString)
    {
        return;
    }
    
    (*valueString) = @"";
}

+ (void)inspectArrayValue:(NSValue *)wrappedValue
                 objCType:(const char *)objCType
              indentLevel:(NSUInteger)indentLevel
                 typeName:(NSMutableString *)typeName
              valueString:(NSString *__autoreleasing *)valueString
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
     typeName:typeName
     valueString:NULL];
    
    [typeName appendFormat:@"[%llu]", count];
    
    if (!valueString)
    {
        return;
    }
    
    NSUInteger arraySize = 0;
    NSUInteger arrayAlignedSize = 0;
    NSGetSizeAndAlignment(objCType, &arraySize, &arrayAlignedSize);
    
    unsigned long long sizePerSubelement = (arraySize / count);
    
    void *arrayValue = calloc((size_t)count, (size_t)sizePerSubelement);
    [wrappedValue getValue:arrayValue];
    
    NSMutableString *arrayValueString = [[NSMutableString alloc] init];
    NSString *indentString = [self indentationWithLevel:indentLevel];
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
            
            NSMutableString *itemTypeName = [[NSMutableString alloc] init];
            NSString *itemValueString;
            [self
             inspectValue:itemValue
             objCType:objCSubType
             indentLevel:(indentLevel + 1)
             typeName:itemTypeName
             valueString:&itemValueString];
            
            [arrayValueString appendFormat:@"  [%llu]: (%@) %@,\n", i, itemTypeName, itemValueString];
            
        }
        
        [arrayValueString appendString:indentString];
    }
    free(arrayValue);
    
    (*valueString) = [NSString stringWithFormat:@"[%@]", arrayValueString];
}

+ (void)inspectUnionValue:(NSValue *)wrappedValue
                 objCType:(const char *)objCType
              indentLevel:(NSUInteger)indentLevel
                 typeName:(NSMutableString *)typeName
              valueString:(NSString *__autoreleasing *)valueString
{
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_UNION_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    [typeName appendFormat:@"union %@", structName];
    
    if (!valueString)
    {
        return;
    }
    
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
    
    (*valueString) = unionString;
}

+ (void)inspectStructValue:(NSValue *)wrappedValue
                  objCType:(const char *)objCType
               indentLevel:(NSUInteger)indentLevel
                  typeName:(NSMutableString *)typeName
               valueString:(NSString *__autoreleasing *)valueString
{
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_STRUCT_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    [typeName appendFormat:@"struct %@", structName];
    
    if (!valueString)
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
        
        (*valueString) = structString;
    }
    else if (wrappedValue)
    {
        (*valueString) = [NSString stringWithFormat:@"{ %@ }", [wrappedValue debugDescription]];
    }
    else
    {
        (*valueString) = @"{ ... }";
    }
}

+ (void)inspectValue:(NSValue *)wrappedValue
            objCType:(const char *)objCType
         indentLevel:(NSUInteger)indentLevel
            typeName:(NSMutableString *)typeName
         valueString:(NSString *__autoreleasing *)valueString
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
            
        case 'D':
            [self
             inspectLongDoubleValue:wrappedValue
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

+ (NSMutableString *)stringForlogHeader:(JELogHeader)header
                               withMask:(JEConsoleLogHeaderMask)mask
{
    NSMutableString *string = [[NSMutableString alloc] init];
    
    if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskDate))
    {
        [string appendFormat:@"%@ ", [[self consoleDateFormatter] stringFromDate:[[NSDate alloc] init]]];
    }
    if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskQueue))
    {
        [string appendFormat:@"[%s] ", dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL)];
    }
    
    if (header.sourceFile != NULL
        && header.functionName != NULL
        && header.lineNumber > 0)
    {
        if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskFile))
        {
            [string appendFormat:
             @"%s:%li ",
             ((strrchr(header.sourceFile, '/') ?: (header.sourceFile - 1)) + 1),
             (long)header.lineNumber];
        }
        if (IsEnumBitSet(mask, JEConsoleLogHeaderMaskFunction))
        {
            [string appendFormat:@"%s ", header.functionName];
        }
    }
    
    if ([string length] > 0)
    {
        [string appendString:@"\n"];
    }
    
    return string;
}


#pragma mark - public

+ (JEConsoleLogHeaderMask)consoleLogHeaderMask
{
    JEConsoleLogHeaderMask __block consoleHeaderMask;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        consoleHeaderMask = [self sharedInstance].consoleLogHeaderMask;
        
    });
    return consoleHeaderMask;
}

+ (void)setConsoleLogHeaderMask:(JEConsoleLogHeaderMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].consoleLogHeaderMask = mask;
        
    });
}

+ (JEConsoleLogHeaderMask)HUDLogHeaderMask
{
    JEConsoleLogHeaderMask __block HUDLogHeaderMask;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        HUDLogHeaderMask = [self sharedInstance].HUDLogHeaderMask;
        
    });
    return HUDLogHeaderMask;
}

+ (void)setHUDLogHeaderMask:(JEConsoleLogHeaderMask)mask
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].HUDLogHeaderMask = mask;
        
    });
}

+ (NSString *)logBulletString
{
    NSString *__block logBulletString;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        logBulletString = [self sharedInstance].logBulletString;
        
    });
    return logBulletString;
}

+ (void)setLogBulletString:(NSString *)logBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].logBulletString = logBulletString;
        
    });
}

+ (NSString *)dumpBulletString
{
    NSString *__block dumpBulletString;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        dumpBulletString = [self sharedInstance].dumpBulletString;
        
    });
    return dumpBulletString;
}

+ (void)setDumpBulletString:(NSString *)dumpBulletString
{
    dispatch_barrier_async([self settingsQueue], ^{
        
        [self sharedInstance].dumpBulletString = dumpBulletString;
        
    });
}

+ (void)dumpValue:(NSValue *)wrappedValue
            label:(NSString *)label
           header:(JELogHeader)header
{
    @autoreleasepool {
        
        NSMutableString *typeName = [[NSMutableString alloc] init];
        NSString *valueString;
        
        [self
         inspectValue:wrappedValue
         objCType:[wrappedValue objCType]
         indentLevel:0
         typeName:typeName
         valueString:&valueString];
        
        JEConsoleLogHeaderMask __block consoleLogHeaderMask;
        JEConsoleLogHeaderMask __block HUDLogHeaderMask;
        NSString *__block logBulletString;
        NSString *__block dumpBulletString;
        dispatch_barrier_sync([self settingsQueue], ^{
            
            JEDebugging *instance = [self sharedInstance];
            consoleLogHeaderMask = instance.consoleLogHeaderMask;
            HUDLogHeaderMask = instance.HUDLogHeaderMask;
            logBulletString = instance.logBulletString;
            dumpBulletString = instance.dumpBulletString;
            
        });
        
        NSMutableString *consoleString = [self
                                          stringForlogHeader:header
                                          withMask:consoleLogHeaderMask];
        [consoleString appendFormat:
         @"%@%@\n  %@(%@) %@\n",
         (logBulletString ?: [self defaultLogBulletString]),
         label,
         (dumpBulletString ?: [self defaultDumpBulletString]),
         typeName,
         valueString];
        
        dispatch_barrier_sync([self consoleQueue], ^{
            
            puts([consoleString UTF8String]);
            
        });
        
    }
}

+ (void)logFormat:(NSString *)format
           header:(JELogHeader)header, ...
{
    va_list arguments;
    va_start(arguments, header);
    NSString *formattedString = [[NSString alloc] initWithFormat:format arguments:arguments];
	va_end(arguments);
    
    JEConsoleLogHeaderMask __block consoleLogHeaderMask;
    JEConsoleLogHeaderMask __block HUDLogHeaderMask;
    NSString *__block logBulletString;
    dispatch_barrier_sync([self settingsQueue], ^{
        
        JEDebugging *instance = [self sharedInstance];
        consoleLogHeaderMask = instance.HUDLogHeaderMask;
        HUDLogHeaderMask = instance.HUDLogHeaderMask;
        logBulletString = instance.logBulletString;
        
    });
    
    NSMutableString *consoleString = [self
                                      stringForlogHeader:header
                                      withMask:consoleLogHeaderMask];
    [consoleString appendFormat:
     @"%@%@\n",
     (logBulletString ?: [self defaultLogBulletString]),
     formattedString];
    
    dispatch_barrier_sync([self consoleQueue], ^{
        
        puts([consoleString UTF8String]);
        
    });
}


@end


#pragma mark - id handlers

@implementation NSObject (JEDebugging)

- (NSMutableString *)_JE_escapedDescription
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:[self debugDescription]];
    static NSDictionary *escapeMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        escapeMapping = @{ @"\0" : @"\\0",
                           @"\a" : @"\\a",
                           @"\b" : @"\\b",
                           @"\f" : @"\\f",
                           @"\n" : @"\\n",
                           @"\r" : @"\\r",
                           @"\t" : @"\\t",
                           @"\v" : @"\\v",
                           @"\"" : @"\\\"" };
        
    });
    
    [description
     replaceOccurrencesOfString:@"\\"
     withString:@"\\\\"
     options:(NSCaseInsensitiveSearch | NSLiteralSearch)
     range:[description range]];
    
    [escapeMapping enumerateKeysAndObjectsUsingBlock:^(NSString *occurrence, NSString *replacement, BOOL *stop) {
        
        [description
         replaceOccurrencesOfString:occurrence
         withString:replacement
         options:(NSCaseInsensitiveSearch | NSLiteralSearch)
         range:[description range]];
        
    }];
    
    [description insertString:@"\"" atIndex:0];
    [description appendString:@"\""];
    
    return description;
}

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString = [self _JE_escapedDescription];
    if (includeAddress)
    {
        [logString
         insertString:[[NSString alloc] initWithFormat:@"<%p> ", self]
         atIndex:0];
    }
    
    return logString;
}

@end


@implementation NSError (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> ", self];
    }
    else
    {
        logString = [[NSMutableString alloc] init];
    }
    
    [logString appendFormat:@"%@(code %li)", [self domain], (long)[self code]];
    
    NSDictionary *userInfo = [self userInfo];
    if ([userInfo count] <= 0)
    {
        return logString;
    }
    
    [logString appendString:@" {"];
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    [userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        @autoreleasepool {
            
            [logString appendFormat:
             @"\n%@%@: (%@ *) %@,",
             indentString,
             [key _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO],
             [obj class],
             [obj _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO]];
            
        }
        
    }];
    
    [logString appendFormat:@"\n%@}", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end


@implementation NSValue (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> (", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"("];
    }
    
    NSString *valueValueString;
    [JEDebugging
     inspectValue:self
     objCType:[self objCType]
     indentLevel:indentLevel
     typeName:logString
     valueString:&valueValueString];
    
    [logString appendFormat:@") %@", valueValueString];
    return logString;
}

@end


@implementation NSDictionary (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> {", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"{"];
    }
    
    if ([self count] <= 0)
    {
        [logString appendString:@"}"];
        return logString;
    }
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        @autoreleasepool {
            
            [logString appendFormat:
             @"\n%@(%@ *) %@: (%@ *) %@,",
             indentString,
             [key class],
             [key _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO],
             [obj class],
             [obj _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO]];
            
        }
        
    }];
    
    [logString appendFormat:@"\n%@}", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end


@implementation NSMapTable (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> {", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"{"];
    }
    
    if ([self count] <= 0)
    {
        [logString appendString:@"}"];
        return logString;
    }
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    for (id key in self)
    {
        @autoreleasepool {
            
            id obj = [self objectForKey:key];
            if (!obj)
            {
                continue;
            }
            
            [logString appendFormat:
             @"\n%@(%@ *) %@: (%@ *) %@,",
             indentString,
             [key class],
             [key _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO],
             [obj class],
             [obj _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO]];
            
        }
    }
    
    [logString appendFormat:@"\n%@}", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end


@implementation NSArray (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> [", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"["];
    }
    
    if ([self count] <= 0)
    {
        [logString appendString:@"]"];
        return logString;
    }
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            [logString appendFormat:
             @"\n%@[%lu]: (%@ *) %@,",
             indentString,
             (unsigned long)idx,
             [obj class],
             [obj _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO]];
            
        }
        
    }];
    
    [logString appendFormat:@"\n%@]", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end


@implementation NSOrderedSet (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> [", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"["];
    }
    
    if ([self count] <= 0)
    {
        [logString appendString:@"]"];
        return logString;
    }
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        @autoreleasepool {
            
            [logString appendFormat:
             @"\n%@[%lu]: (%@ *) %@,",
             indentString,
             (unsigned long)idx,
             [obj class],
             [obj _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO]];
            
        }
        
    }];
    
    [logString appendFormat:@"\n%@]", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end


@implementation NSPointerArray (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> [", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"["];
    }
    
    NSUInteger count = [self count];
    if (count <= 0)
    {
        [logString appendString:@"]"];
        return logString;
    }
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    for (NSInteger idx = 0; idx < count; ++idx)
    {
        @autoreleasepool {
            
            void *pointer = [self pointerAtIndex:idx];
            
            [logString appendFormat:
             @"\n%@[%lu]: (void *) <%p>,",
             indentString,
             (unsigned long)idx,
             pointer];
            
        }
    }
    
    [logString appendFormat:@"\n%@]", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end


@implementation NSSet (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> (", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"("];
    }
    
    if ([self count] <= 0)
    {
        [logString appendString:@")"];
        return logString;
    }
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        
        @autoreleasepool {
            
            [logString appendFormat:
             @"\n%@(%@ *) %@,",
             indentString,
             [obj class],
             [obj _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO]];
            
        }
        
    }];
    
    [logString appendFormat:@"\n%@)", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end


@implementation NSHashTable (JEDebugging)

- (NSMutableString *)_JE_logStringWithIndentLevel:(NSUInteger)indentLevel
                                   includeAddress:(BOOL)includeAddress
{
    NSMutableString *logString;
    if (includeAddress)
    {
        logString = [[NSMutableString alloc] initWithFormat:@"<%p> (", self];
    }
    else
    {
        logString = [[NSMutableString alloc] initWithString:@"("];
    }
    
    if ([self count] <= 0)
    {
        [logString appendString:@")"];
        return logString;
    }
    
    NSUInteger nextIndentLevel = (indentLevel + 1);
    NSString *indentString = [JEDebugging indentationWithLevel:nextIndentLevel];
    for (id obj in self)
    {
        @autoreleasepool {
            
            [logString appendFormat:
             @"\n%@(%@ *) %@,",
             indentString,
             [obj class],
             [obj _JE_logStringWithIndentLevel:nextIndentLevel
                                includeAddress:NO]];
            
        }
    }
    
    [logString appendFormat:@"\n%@)", [JEDebugging indentationWithLevel:indentLevel]];
    
    return logString;
}

@end

