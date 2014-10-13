//
//  NSValue+JEDebugging.m
//  JEToolkit
//
//  Copyright (c) 2013 John Rommel Estropia
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "NSValue+JEDebugging.h"

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "NSString+JEToolkit.h"
#import "NSMutableString+JEDebugging.h"
#import "NSObject+JEDebugging.h"


@implementation NSValue (JEDebugging)

#pragma mark - NSObject

- (NSString *)debugDescription {
    
    // override any existing implementation
    return [super debugDescription];
}


#pragma mark - NSObject+JEDebugging

- (NSString *)loggingDescription {
    
    NSMutableString *typeNameBuilder = [[NSMutableString alloc] init];
    NSMutableString *valueStringBuilder = [[NSMutableString alloc] init];
    
    [NSValue
     appendDetailsForForValue:self
     expectedObjCType:[self objCType]
     typeNameBuilder:typeNameBuilder
     valueStringBuilder:valueStringBuilder];
    
    return [NSString stringWithFormat:
            @"(%@) %@",
            typeNameBuilder, valueStringBuilder];
}


#pragma mark - Private

+ (NSNumberFormatter *)integerFormatter {
    
    static NSNumberFormatter *integerFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.allowsFloats = NO;
        integerFormatter = formatter;
        
    });
    return integerFormatter;
}

+ (void)appendDetailsForForValue:(NSValue *)wrappedValue
                expectedObjCType:(const char [])objCType
                 typeNameBuilder:(NSMutableString *)typeNameBuilder
              valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    if (!objCType || strlen(objCType) < 1) {
        
        [self appendDetailsForForUndefinedValueWithTypeNameBuilder:typeNameBuilder];
        return;
    }
    
    switch (objCType[0]) {
            
        case _C_ID:
            [self
             appendDetailsForForIdValue:wrappedValue
             expectedObjCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_CLASS:
            [self
             appendDetailsForForClassValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_SEL:
            [self
             appendDetailsForForSelectorValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_CHR:
            [self
             appendDetailsForForCharValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UCHR:
            [self
             appendDetailsForForUnsignedCharValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_SHT:
            [self
             appendDetailsForForShortValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_USHT:
            [self
             appendDetailsForForUnsignedShortValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_INT:
            [self
             appendDetailsForForIntValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UINT:
            [self
             appendDetailsForForUnsignedIntValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_LNG:
            [self
             appendDetailsForForLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_ULNG:
            [self
             appendDetailsForForUnsignedLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_LNG_LNG:
            [self
             appendDetailsForForLongLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_ULNG_LNG:
            [self
             appendDetailsForForUnsignedLongLongValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_FLT:
            [self
             appendDetailsForForFloatValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_DBL:
            [self
             appendDetailsForForDoubleValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case 'D': // long double
            [self
             appendDetailsForForLongDoubleValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_BFLD:
            [self
             appendDetailsForForBitFieldValue:wrappedValue
             expectedObjCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_BOOL:
            [self
             appendDetailsForForBoolValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_VOID:
            [self appendDetailsForForVoidValueWithTypeNameBuilder:typeNameBuilder];
            break;
            
        case _C_PTR:
            [self
             appendDetailsForForPointerValue:wrappedValue
             expectedObjCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_CHARPTR:
            [self
             appendDetailsForForCStringValue:wrappedValue
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_ARY_B:
            [self
             appendDetailsForForArrayValue:wrappedValue
             expectedObjCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UNION_B:
            [self
             appendDetailsForForUnionValue:wrappedValue
             expectedObjCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_STRUCT_B:
            [self
             appendDetailsForStructValue:wrappedValue
             expectedObjCType:objCType
             typeNameBuilder:typeNameBuilder
             valueStringBuilder:valueStringBuilder];
            break;
            
        case _C_UNDEF:
        case _C_ATOM:
        case _C_VECTOR:
        default:
            [self appendDetailsForForUndefinedValueWithTypeNameBuilder:typeNameBuilder];
            break;
    }
}

+ (void)appendDetailsForForIdValue:(NSValue *)wrappedValue
                  expectedObjCType:(const char [])objCType
                   typeNameBuilder:(NSMutableString *)typeNameBuilder
                valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    id __unsafe_unretained idValue = nil;
    [wrappedValue getValue:&idValue];
    
    if (idValue) {
        
        [typeNameBuilder appendFormat:@"%@ *", [idValue class]];
    }
    else {
        
        [typeNameBuilder appendString:@"id"];
    }
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    if (!idValue) {
        
        [valueStringBuilder appendString:@"nil"];
        return;
    }
    
    if ((strlen(objCType) > 1) && (objCType[1] == _C_UNDEF)) {
        
        [valueStringBuilder appendFormat:@"<%p> ", idValue];
        
        struct _JEBlockLiteral {
            
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
        
        typedef NS_OPTIONS(NSUInteger, _JEBlockDescriptionFlags) {
            
            _JEBlockDescriptionFlagsHasCopyDispose  = (1 << 25),
            _JEBlockDescriptionFlagsHasCtor         = (1 << 26), // helpers have C++ code
            _JEBlockDescriptionFlagsIsGlobal        = (1 << 28),
            _JEBlockDescriptionFlagsHasStret        = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
            _JEBlockDescriptionFlagsHasSignature    = (1 << 30)
        };
        
        struct _JEBlockLiteral *blockRef = (__bridge struct _JEBlockLiteral *)idValue;
        _JEBlockDescriptionFlags blockFlags = blockRef->flags;
        
        if (blockFlags & _JEBlockDescriptionFlagsHasSignature) {
            
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
                
                [self
                 appendDetailsForForValue:nil
                 expectedObjCType:[blockSignature methodReturnType]
                 typeNameBuilder:valueStringBuilder
                 valueStringBuilder:NULL];
                [valueStringBuilder appendString:@"(^)"];
                
            }
            
            NSUInteger argCount = [blockSignature numberOfArguments];
            if (argCount <= 1) {
                
                [valueStringBuilder appendFormat:@"(void)"];
            }
            else {
                
                [valueStringBuilder appendString:@"("];
                
                for (NSUInteger i = 1; i < argCount; ++i) {
                    
                    @autoreleasepool {
                        
                        if (i > 1) {
                            
                            [valueStringBuilder appendString:@", "];
                        }
                        
                        [self
                         appendDetailsForForValue:nil
                         expectedObjCType:[blockSignature getArgumentTypeAtIndex:i]
                         typeNameBuilder:valueStringBuilder
                         valueStringBuilder:NULL];
                        
                    }
                }
                [valueStringBuilder appendString:@")"];
            }
        }
    }
    else {
        
        [valueStringBuilder appendString:[idValue
                                          loggingDescriptionIncludeClass:NO
                                          includeAddress:YES]];
    }
}

+ (void)appendDetailsForForClassValue:(NSValue *)wrappedValue
                      typeNameBuilder:(NSMutableString *)typeNameBuilder
                   valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"Class"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    Class classValue = Nil;
    [wrappedValue getValue:&classValue];
    [valueStringBuilder appendString:(NSStringFromClass(classValue) ?: @"Nil")];
}

+ (void)appendDetailsForForSelectorValue:(NSValue *)wrappedValue
                         typeNameBuilder:(NSMutableString *)typeNameBuilder
                      valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"SEL"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    SEL selectorValue = NULL;
    [wrappedValue getValue:&selectorValue];
    [valueStringBuilder appendString:(NSStringFromSelector(selectorValue) ?: @"NULL")];
}

+ (void)appendDetailsForForCharValue:(NSValue *)wrappedValue
                     typeNameBuilder:(NSMutableString *)typeNameBuilder
                  valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"char"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    char charValue = '\0';
    [wrappedValue getValue:&charValue];
    
    static NSDictionary *replacementMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // http://en.wikipedia.org/wiki/ASCII
        replacementMapping = @{ @"\0" : @"\\0",
                                @"\a" : @"\\a",
                                @"\b" : @"\\b",
                                @"\t" : @"\\t",
                                @"\n" : @"\\n",
                                @"\v" : @"\\v",
                                @"\f" : @"\\f",
                                @"\r" : @"\\r",
                                @"\e" : @"\\e",
                                @"\'" : @"\\\'",
                                @"\\" : @"\\\\" };
        
    });
    
    NSString *charMapping = replacementMapping[[[NSString alloc]
                                                initWithCharacters:(unichar[]){ charValue }
                                                length:1]];
    if (charMapping) {
        
        [valueStringBuilder appendFormat:@"'%@' (%i)", charMapping, charValue];
    }
    else if (charValue < ' ' || charValue > '~') {
        
        [valueStringBuilder appendFormat:@"'\\x%1$02u' (%1$i)", charValue];
    }
    else {
        
        [valueStringBuilder appendFormat:@"'%1$c' (%1$i)", charValue];
    }
}

+ (void)appendDetailsForForUnsignedCharValue:(NSValue *)wrappedValue
                             typeNameBuilder:(NSMutableString *)typeNameBuilder
                          valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"unsigned char"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    unsigned char unsignedCharValue = 0;
    [wrappedValue getValue:&unsignedCharValue];
    [valueStringBuilder appendFormat:@"%u", unsignedCharValue];
}

+ (void)appendDetailsForForShortValue:(NSValue *)wrappedValue
                      typeNameBuilder:(NSMutableString *)typeNameBuilder
                   valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"short"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    short shortValue = 0;
    [wrappedValue getValue:&shortValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(shortValue)]];
}

+ (void)appendDetailsForForUnsignedShortValue:(NSValue *)wrappedValue
                              typeNameBuilder:(NSMutableString *)typeNameBuilder
                           valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"unsigned short"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    unsigned short unsignedShortValue = 0;
    [wrappedValue getValue:&unsignedShortValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(unsignedShortValue)]];
}

+ (void)appendDetailsForForIntValue:(NSValue *)wrappedValue
                    typeNameBuilder:(NSMutableString *)typeNameBuilder
                 valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"int"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    int intValue = 0;
    [wrappedValue getValue:&intValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(intValue)]];
}

+ (void)appendDetailsForForUnsignedIntValue:(NSValue *)wrappedValue
                            typeNameBuilder:(NSMutableString *)typeNameBuilder
                         valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"unsigned int"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    unsigned int unsignedIntValue = 0;
    [wrappedValue getValue:&unsignedIntValue];
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(unsignedIntValue)]];
}

+ (void)appendDetailsForForLongValue:(NSValue *)wrappedValue
                     typeNameBuilder:(NSMutableString *)typeNameBuilder
                  valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"long"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    long longValue = 0;
    [wrappedValue getValue:&longValue];
    [valueStringBuilder appendFormat:@"%li", longValue];
}

+ (void)appendDetailsForForUnsignedLongValue:(NSValue *)wrappedValue
                             typeNameBuilder:(NSMutableString *)typeNameBuilder
                          valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"unsigned long"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    unsigned long unsignedLongValue = 0;
    [wrappedValue getValue:&unsignedLongValue];
    [valueStringBuilder appendFormat:@"%lu", unsignedLongValue];
}

+ (void)appendDetailsForForLongLongValue:(NSValue *)wrappedValue
                         typeNameBuilder:(NSMutableString *)typeNameBuilder
                      valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"long long"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    long long longlongValue = 0;
    [wrappedValue getValue:&longlongValue];
    [valueStringBuilder appendFormat:@"%lli", longlongValue];
}

+ (void)appendDetailsForForUnsignedLongLongValue:(NSValue *)wrappedValue
                                 typeNameBuilder:(NSMutableString *)typeNameBuilder
                              valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"unsigned long long"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    unsigned long long unsignedLonglongValue = 0;
    [wrappedValue getValue:&unsignedLonglongValue];
    [valueStringBuilder appendFormat:@"%llu", unsignedLonglongValue];
}

+ (void)appendDetailsForForFloatValue:(NSValue *)wrappedValue
                      typeNameBuilder:(NSMutableString *)typeNameBuilder
                   valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"float"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    float floatValue = 0.0f;
    [wrappedValue getValue:&floatValue];
    
    static const int _JREDecimalDigits = 9;
    
    if (floatValue >= (powf(10.0f, (_JREDecimalDigits - 1)))) {
        
        [valueStringBuilder appendFormat:@"%.*e", FLT_DIG, floatValue];
    }
    else {
        
        [valueStringBuilder appendFormat:@"%.*g", _JREDecimalDigits, floatValue];
    }
}

+ (void)appendDetailsForForDoubleValue:(NSValue *)wrappedValue
                       typeNameBuilder:(NSMutableString *)typeNameBuilder
                    valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"double"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    double doubleValue = 0.0;
    [wrappedValue getValue:&doubleValue];
    
    static const int _JREDecimalDigits = 17;
    
    if (doubleValue >= (pow(10.0, (_JREDecimalDigits - 1)))) {
        
        [valueStringBuilder appendFormat:@"%.*e", DBL_DIG, doubleValue];
    }
    else {
        
        [valueStringBuilder appendFormat:@"%.*g", _JREDecimalDigits, doubleValue];
    }
}

+ (void)appendDetailsForForLongDoubleValue:(NSValue *)wrappedValue
                           typeNameBuilder:(NSMutableString *)typeNameBuilder
                        valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"long double"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    long double longDoubleValue = 0.0l;
    [wrappedValue getValue:&longDoubleValue];
    
    static const int _JREDecimalDigits = 21;
    
    if (longDoubleValue >= (powl(10.0l, (_JREDecimalDigits - 1)))) {
        
        [valueStringBuilder appendFormat:@"%.*Le", LDBL_DIG, longDoubleValue];
    }
    else {
        
        [valueStringBuilder appendFormat:@"%.*Lg", _JREDecimalDigits, longDoubleValue];
    }
}

+ (void)appendDetailsForForBitFieldValue:(NSValue *)wrappedValue
                        expectedObjCType:(const char [])objCType
                         typeNameBuilder:(NSMutableString *)typeNameBuilder
                      valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    // Note that currently it is impossible to reach this code.
    // A bug(?) with NSGetSizeAndAlignment prevents structs and unions with bitfields to be wrapped in NSValue, in which case the NSValue for the containing struct will be nil in the first place.
    // The code below is for future reference only.
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:[[NSString alloc] initWithUTF8String:(objCType + 1)]];
    
    unsigned long long bitCount = 0;
    [scanner scanUnsignedLongLong:&bitCount];
    
    [typeNameBuilder appendFormat:@"%llubit", bitCount];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    // https://developer.apple.com/library/ios/DOCUMENTATION/Cocoa/Conceptual/Archiving/Articles/codingctypes.html
    unsigned long long bitFieldValue = 0;
    [wrappedValue getValue:&bitFieldValue];
    
    const unsigned long long shiftCount = (sizeof(bitFieldValue) - bitCount);
    bitFieldValue = ((bitFieldValue << shiftCount) >> shiftCount);
    
    [valueStringBuilder appendString:[[self integerFormatter] stringFromNumber:@(bitFieldValue)]];
}

+ (void)appendDetailsForForBoolValue:(NSValue *)wrappedValue
                     typeNameBuilder:(NSMutableString *)typeNameBuilder
                  valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"bool"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    bool boolValue = false;
    [wrappedValue getValue:&boolValue];
    [valueStringBuilder appendString:(boolValue ? @"true" : @"false")];
}

+ (void)appendDetailsForForVoidValueWithTypeNameBuilder:(NSMutableString *)typeNameBuilder {
    
    [typeNameBuilder appendString:@"void"];
}

+ (void)appendDetailsForForUndefinedValueWithTypeNameBuilder:(NSMutableString *)typeNameBuilder {
    
    [typeNameBuilder appendString:@"?"];
}

+ (void)appendDetailsForForPointerValue:(NSValue *)wrappedValue
                       expectedObjCType:(const char [])objCType
                        typeNameBuilder:(NSMutableString *)typeNameBuilder
                     valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    if (strlen(objCType) < 2) {
        
        [self appendDetailsForForUndefinedValueWithTypeNameBuilder:typeNameBuilder];
        return;
    }
    
    const void *pointerValue = NULL;
    [wrappedValue getValue:&pointerValue];
    
    objCType++;
    if (objCType[0] == _C_UNDEF) {
        
        [typeNameBuilder appendString:@"func *"];
        
        if (!valueStringBuilder) {
            
            return;
        }
        
        if (pointerValue) {
            
            [valueStringBuilder appendFormat:@"<%p>", pointerValue];
        }
        else {
            
            [valueStringBuilder appendString:@"NULL"];
        }
    }
    else {
        
        if (pointerValue) {
            
            [valueStringBuilder appendFormat:@"<%p> ", pointerValue];
        }
        else {
            
            [valueStringBuilder appendString:@"NULL"];
        }
        
        [self
         appendDetailsForForValue:(pointerValue
                                   ? [[NSValue alloc] initWithBytes:pointerValue objCType:objCType]
                                   : nil)
         expectedObjCType:objCType
         typeNameBuilder:typeNameBuilder
         valueStringBuilder:(pointerValue ? valueStringBuilder : nil)];
        
        [typeNameBuilder appendString:([typeNameBuilder hasSuffix:@"*"]
                                       ? @"*"
                                       : @" *")];
    }
}

+ (void)appendDetailsForForCStringValue:(NSValue *)wrappedValue
                        typeNameBuilder:(NSMutableString *)typeNameBuilder
                     valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    [typeNameBuilder appendString:@"char *"];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    const char *cstringValue = NULL;
    [wrappedValue getValue:&cstringValue];
    
    if (cstringValue) {
        
        NSMutableString *escapedString = [[NSMutableString alloc] initWithUTF8String:cstringValue];
        [escapedString escapeWithUTF8CStringRepresentation];
        [valueStringBuilder appendFormat:@"<%p> %@", cstringValue, escapedString];
    }
    else {
        
        [valueStringBuilder appendString:@"NULL"];
    }
}

+ (void)appendDetailsForForAtomValueWithTypeNameBuilder:(NSMutableString *)typeNameBuilder {
    
    [typeNameBuilder appendString:@"atom"];
}

+ (void)appendDetailsForForArrayValue:(NSValue *)wrappedValue
                     expectedObjCType:(const char [])objCType
                      typeNameBuilder:(NSMutableString *)typeNameBuilder
                   valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    if (strlen(objCType) < 2) {
        
        [self appendDetailsForForUndefinedValueWithTypeNameBuilder:typeNameBuilder];
        return;
    }
    
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
     appendDetailsForForValue:nil
     expectedObjCType:objCSubType
     typeNameBuilder:typeNameBuilder
     valueStringBuilder:NULL];
    
    [typeNameBuilder appendFormat:@"[%llu]", count];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    if (count <= 0) {
        
        [valueStringBuilder appendString:@"[]"];
        return;
    }
    
    NSUInteger arraySize = 0;
    NSUInteger arrayAlignedSize = 0;
    NSGetSizeAndAlignment(objCType, &arraySize, &arrayAlignedSize);
    
    unsigned long long sizePerSubelement = (arraySize / count);
    
    void *arrayValue = calloc((size_t)count, (size_t)sizePerSubelement);
    [wrappedValue getValue:arrayValue];
    
    NSMutableString *valueString = [[NSMutableString alloc] initWithString:@"["];
    for (unsigned long long i = 0; i < count; ++i) {
        
        if (i > 0) {
            
            [valueString appendString:@",\n"];
        }
        else {
            
            [valueString appendString:@"\n"];
        }
        
        NSValue *itemValue = [[NSValue alloc]
                              initWithBytes:(arrayValue + (i * sizePerSubelement))
                              objCType:objCSubType];
        
        @autoreleasepool {
            
            [valueString appendFormat:@"[%llu]: (", i];
            
            NSMutableString *itemValueString = [[NSMutableString alloc] init];
            [self
             appendDetailsForForValue:itemValue
             expectedObjCType:objCSubType
             typeNameBuilder:valueString
             valueStringBuilder:itemValueString];
            
            [valueString appendString:@") "];
            [valueString appendString:itemValueString];
            
        }
    }
    free(arrayValue);
    
    [valueString indentByLevel:1];
    [valueString appendString:@"\n]"];
    [valueStringBuilder appendString:valueString];
}

+ (void)appendDetailsForForUnionValue:(NSValue *)wrappedValue
                     expectedObjCType:(const char [])objCType
                      typeNameBuilder:(NSMutableString *)typeNameBuilder
                   valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    if (strlen(objCType) < 2) {
        
        [self appendDetailsForForUndefinedValueWithTypeNameBuilder:typeNameBuilder];
        return;
    }
    
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_UNION_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    [typeNameBuilder appendFormat:@"union %@", structName];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    NSString *description = [wrappedValue description];
    if (([NSString isNilOrEmptyString:description] || [description length] == 2)
        && [description hasPrefix:@"<"]
        && [description hasSuffix:@">"]) {
        
        description = @"...";
    }
    [valueStringBuilder appendFormat:@"{ %@ }", description];
}

+ (void)appendDetailsForStructValue:(NSValue *)wrappedValue
                   expectedObjCType:(const char [])objCType
                    typeNameBuilder:(NSMutableString *)typeNameBuilder
                 valueStringBuilder:(NSMutableString *)valueStringBuilder {
    
    if (strlen(objCType) < 2) {
        
        [self appendDetailsForForUndefinedValueWithTypeNameBuilder:typeNameBuilder];
        return;
    }
    
    NSString *substring = @((objCType + 1));
    NSScanner *scanner = [[NSScanner alloc] initWithString:
                          [substring substringToIndex:
                           [substring rangeOfString:[[NSString alloc] initWithFormat:@"%c", _C_STRUCT_E]
                                            options:(NSLiteralSearch | NSBackwardsSearch)].location]];
    
    NSString *structName;
    [scanner scanUpToString:@"=" intoString:&structName];
    
    [typeNameBuilder appendFormat:@"struct %@", structName];
    
    if (!valueStringBuilder) {
        
        return;
    }
    
    static NSMutableDictionary *structHandlers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSMutableDictionary *blockDictionary = [[NSMutableDictionary alloc] init];
        blockDictionary[@(@encode(CGPoint))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            CGPoint point = [structValue CGPointValue];
            [stringBuilder appendFormat:
             @"{ x:%g, y:%g }",
             point.x, point.y];
            
        } copy];
        blockDictionary[@(@encode(CGSize))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            CGSize size = [structValue CGSizeValue];
            [stringBuilder appendFormat:
             @"{ width:%g, height:%g }",
             size.width, size.height];
            
        } copy];
        blockDictionary[@(@encode(CGRect))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            CGRect rect = [structValue CGRectValue];
            [stringBuilder appendFormat:
             @"{ x:%g, y:%g, width:%g, height:%g }",
             rect.origin.x, rect.origin.y, rect.size.width, rect.size.height];
            
        } copy];
        blockDictionary[@(@encode(CGAffineTransform))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            CGAffineTransform affineTransform = [structValue CGAffineTransformValue];
            [stringBuilder appendFormat:
             @"{\n"
             "   a:%g, b:%g, c:%g, d:%g,\n"
             "   tx:%g, ty:%g\n"
             "}",
             affineTransform.a, affineTransform.b, affineTransform.c, affineTransform.d,
             affineTransform.tx, affineTransform.ty];
            
        } copy];
#if CGVECTOR_DEFINED
        blockDictionary[@(@encode(CGVector))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            CGVector vector = {};
            [structValue getValue:&vector];
            [stringBuilder appendFormat:
             @"{ dx:%g, dy:%g }",
             vector.dx, vector.dy];
            
        } copy];
#endif
        blockDictionary[@(@encode(UIEdgeInsets))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            UIEdgeInsets edgeInsets = [structValue UIEdgeInsetsValue];
            [stringBuilder appendFormat:
             @"{ top:%g, left:%g, bottom:%g, right:%g }",
             edgeInsets.top, edgeInsets.left, edgeInsets.bottom, edgeInsets.right];
            
        } copy];
        blockDictionary[@(@encode(UIOffset))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            UIOffset offset = [structValue UIOffsetValue];
            [stringBuilder appendFormat:
             @"{ horizontal:%g, vertical:%g }",
             offset.horizontal, offset.vertical];
            
        } copy];
        blockDictionary[@(@encode(NSRange))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            NSRange range = [structValue rangeValue];
            [stringBuilder appendFormat:
             @"{ location:%lu, length:%lu }",
             (unsigned long)range.location, (unsigned long)range.length];
            
        } copy];
        
        // common structures for unnamed structs
        union {
            struct {
                CGFloat f1; CGFloat f2;
            } _je_structFF;
            struct {
                struct { CGFloat f1; CGFloat f2; } s1;
                struct { CGFloat f1; CGFloat f2; } s2;
            } _je_structFFFF;
            struct {
                double d1; double d2;
            } _je_structDD;
            struct {
                struct { double d1; double d2; } s1;
                struct { double d1; double d2; } s2;
            } _je_structDDDD;
        } _je_structProxy;
        
        blockDictionary[@(@encode(typeof(_je_structProxy._je_structFF)))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            typeof(_je_structProxy) proxy = {};
            [structValue getValue:&proxy];
            [stringBuilder appendFormat:
             @"{ %g, %g }",
             proxy._je_structFF.f1, proxy._je_structFF.f2];
            
        } copy];
        blockDictionary[@(@encode(typeof(_je_structProxy._je_structFFFF)))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            typeof(_je_structProxy) proxy = {};
            [structValue getValue:&proxy];
            [stringBuilder appendFormat:
             @"{ { %g, %g }, { %g, %g } }",
             proxy._je_structFFFF.s1.f1, proxy._je_structFFFF.s1.f2,
             proxy._je_structFFFF.s2.f1, proxy._je_structFFFF.s2.f2];
            
        } copy];
        blockDictionary[@(@encode(typeof(_je_structProxy._je_structDD)))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            typeof(_je_structProxy) proxy = {};
            [structValue getValue:&proxy];
            [stringBuilder appendFormat:
             @"{ %g, %g }",
             proxy._je_structDD.d1, proxy._je_structDD.d2];
            
        } copy];
        blockDictionary[@(@encode(typeof(_je_structProxy._je_structDDDD)))] = [^(NSValue *structValue, NSMutableString *stringBuilder){
            
            typeof(_je_structProxy) proxy = {};
            [structValue getValue:&proxy];
            [stringBuilder appendFormat:
             @"{ { %g, %g }, { %g, %g } }",
             proxy._je_structDDDD.s1.d1,
             proxy._je_structDDDD.s1.d2,
             proxy._je_structDDDD.s2.d1,
             proxy._je_structDDDD.s2.d2];
            
        } copy];
        
        structHandlers = blockDictionary;
        
    });
    
    void (^getStructString)(NSValue *structValue, NSMutableString *stringBuilder) = structHandlers[@(objCType)];
    if (getStructString) {
        
        getStructString(wrappedValue, valueStringBuilder);
    }
    else {
        
        NSString *description = [wrappedValue description];
        if (([NSString isNilOrEmptyString:description] || [description length] == 2 )
            && [description hasPrefix:@"<"]
            && [description hasSuffix:@">"]) {
            
            description = @"...";
        }
        [valueStringBuilder appendFormat:@"{ %@ }", description];
    }
}


@end
