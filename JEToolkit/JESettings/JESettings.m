//
//  JESettingsBase.m
//  JEToolkit
//
//  Copyright (c) 2014 John Rommel Estropia
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

#import "JESettings.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@implementation JESettings

#pragma mark - NSObject

+ (void)initialize {
    
    Class contextClass = self;
    unsigned int numberOfProperties = 0;
    objc_property_t *properties = class_copyPropertyList(contextClass, &numberOfProperties);
    
    for (unsigned int i = 0; i < numberOfProperties; ++i) {
        
        @autoreleasepool {
            
            objc_property_t property = properties[i];
            NSString *propertyName = [[NSString alloc]
                                      initWithCString:property_getName(property)
                                      encoding:NSUTF8StringEncoding];
            NSString *objcType;
            NSString *getterName = propertyName;
            NSString *setterName = [NSString stringWithFormat:
                                    @"set%@%@:",
                                    [[propertyName substringToIndex:1] uppercaseString],
                                    [propertyName substringFromIndex:1]];
            BOOL isReadOnly = NO;
            BOOL isDynamic = NO;
            for (NSString *attribute in [[[NSString alloc]
                                          initWithCString:property_getAttributes(property)
                                          encoding:NSUTF8StringEncoding] componentsSeparatedByString:@","]) {
                // https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
                switch (attribute.UTF8String[0]) {
                    case 'D':
                        isDynamic = YES;
                        break;
                    case 'G':
                        getterName = [attribute substringFromIndex:1];
                        break;
                    case 'R':
                        isReadOnly = YES;
                        break;
                    case 'S':
                        setterName = [attribute substringFromIndex:1];
                        break;
                    case 'T':
                        objcType = [attribute substringFromIndex:1];
                        break;
                    default:
                        break;
                }
            }
            if (isReadOnly
                || !isDynamic
                || !objcType) {
                
                continue;
            }
            
            SEL getterSelector = sel_registerName(getterName.UTF8String);
            SEL setterSelector = sel_registerName(setterName.UTF8String);
            
            IMP getterImplementation = NULL;
            IMP setterImplementation = NULL;
            switch (objcType.UTF8String[0]) {
                    
                case _C_CHR:
                case _C_SHT:
                case _C_INT:
                case _C_LNG:
                case _C_LNG_LNG: {
                    
                    getterImplementation = imp_implementationWithBlock(^long long int(JESettings *self, SEL _cmd) {
                        
                        return [self integerValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, long long int value) {
                        
                        [self setIntegerValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_UCHR:
                case _C_USHT:
                case _C_UINT:
                case _C_ULNG:
                case _C_ULNG_LNG: {
                    
                    getterImplementation = imp_implementationWithBlock(^unsigned long long int(JESettings *self, SEL _cmd) {
                        
                        return [self unsignedIntegerValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, unsigned long long int value) {
                        
                        [self setUnsignedIntegerValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_BOOL: {
                    
                    getterImplementation = imp_implementationWithBlock(^bool(JESettings *self, SEL _cmd) {
                        
                        return [self booleanValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, bool value) {
                        
                        [self setBooleanValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_FLT: {
                    
                    getterImplementation = imp_implementationWithBlock(^float(JESettings *self, SEL _cmd) {
                        
                        return [self floatValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, float value) {
                        
                        [self setFloatValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_DBL: {
                    
                    getterImplementation = imp_implementationWithBlock(^double(JESettings *self, SEL _cmd) {
                        
                        return [self doubleValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, double value) {
                        
                        [self setDoubleValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_ID: {
                    
                    NSString *className = [[[objcType substringFromIndex:1] componentsSeparatedByString:@"\""] componentsJoinedByString:@""];
                    Class type = NSClassFromString(className);
                    objcType = @"@";
                    
                    if ([type isSubclassOfClass:[NSString class]]) {
                        
                        getterImplementation = imp_implementationWithBlock(^NSString *(JESettings *self, SEL _cmd) {
                            
                            return [self NSStringValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, NSString *value) {
                            
                            [self setNSStringValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([type isSubclassOfClass:[NSNumber class]]) {
                        
                        getterImplementation = imp_implementationWithBlock(^NSNumber *(JESettings *self, SEL _cmd) {
                            
                            return [self NSNumberValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, NSNumber *value) {
                            
                            [self setNSNumberValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([type isSubclassOfClass:[NSDate class]]) {
                        
                        getterImplementation = imp_implementationWithBlock(^NSDate *(JESettings *self, SEL _cmd) {
                            
                            return [self NSDateValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, NSDate *value) {
                            
                            [self setNSDateValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([type isSubclassOfClass:[NSData class]]) {
                        
                        getterImplementation = imp_implementationWithBlock(^NSData *(JESettings *self, SEL _cmd) {
                            
                            return [self NSDataValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, NSData *value) {
                            
                            [self setNSDataValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([type isSubclassOfClass:[NSURL class]]) {
                        
                        getterImplementation = imp_implementationWithBlock(^NSURL *(JESettings *self, SEL _cmd) {
                            
                            return [self NSURLValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, NSURL *value) {
                            
                            [self setNSURLValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([type isSubclassOfClass:[NSUUID class]]) {
                        
                        getterImplementation = imp_implementationWithBlock(^NSUUID *(JESettings *self, SEL _cmd) {
                            
                            return [self NSUUIDValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, NSUUID *value) {
                            
                            [self setNSUUIDValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([type conformsToProtocol:@protocol(NSCoding)]) {
                        
                        getterImplementation = imp_implementationWithBlock(^id<NSCoding>(JESettings *self, SEL _cmd) {
                            
                            return [self NSCodingValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, id<NSCoding> value) {
                            
                            [self setNSCodingValue:value forKey:propertyName];
                        });
                        break;
                    }
                    
                    getterImplementation = imp_implementationWithBlock(^id(JESettings *self, SEL _cmd) {
                        
                        return [self idValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, id value) {
                        
                        [self setIdValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_CLASS: {
                    
                    getterImplementation = imp_implementationWithBlock(^Class(JESettings *self, SEL _cmd) {
                        
                        return [self classValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, Class value) {
                        
                        [self setClassValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_SEL: {
                    
                    getterImplementation = imp_implementationWithBlock(^SEL(JESettings *self, SEL _cmd) {
                        
                        return [self selectorValueForKey:propertyName];
                    });
                    setterImplementation = imp_implementationWithBlock(^(JESettings *self, SEL value) {
                        
                        [self setSelectorValue:value forKey:propertyName];
                    });
                    break;
                }
                    
                case _C_STRUCT_B: {
                    
                    if ([objcType isEqualToString:@(@encode(CGPoint))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^CGPoint(JESettings *self, SEL _cmd) {
                            
                            return [self CGPointValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, CGPoint value) {
                            
                            [self setCGPointValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([objcType isEqualToString:@(@encode(CGSize))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^CGSize(JESettings *self, SEL _cmd) {
                            
                            return [self CGSizeValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, CGSize value) {
                            
                            [self setCGSizeValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([objcType isEqualToString:@(@encode(CGRect))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^CGRect(JESettings *self, SEL _cmd) {
                            
                            return [self CGRectValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, CGRect value) {
                            
                            [self setCGRectValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([objcType isEqualToString:@(@encode(CGAffineTransform))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^CGAffineTransform(JESettings *self, SEL _cmd) {
                            
                            return [self CGAffineTransformValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, CGAffineTransform value) {
                            
                            [self setCGAffineTransformValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([objcType isEqualToString:@(@encode(CGVector))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^CGVector(JESettings *self, SEL _cmd) {
                            
                            return [self CGVectorValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, CGVector value) {
                            
                            [self setCGVectorValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([objcType isEqualToString:@(@encode(UIEdgeInsets))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^UIEdgeInsets(JESettings *self, SEL _cmd) {
                            
                            return [self UIEdgeInsetsValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, UIEdgeInsets value) {
                            
                            [self setUIEdgeInsetsValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([objcType isEqualToString:@(@encode(UIOffset))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^UIOffset(JESettings *self, SEL _cmd) {
                            
                            return [self UIOffsetValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, UIOffset value) {
                            
                            [self setUIOffsetValue:value forKey:propertyName];
                        });
                        break;
                    }
                    if ([objcType isEqualToString:@(@encode(NSRange))]) {
                        
                        getterImplementation = imp_implementationWithBlock(^NSRange(JESettings *self, SEL _cmd) {
                            
                            return [self NSRangeValueForKey:propertyName];
                        });
                        setterImplementation = imp_implementationWithBlock(^(JESettings *self, NSRange value) {
                            
                            [self setNSRangeValue:value forKey:propertyName];
                        });
                        break;
                    }
                }
                    
                default:
                    free(properties);
                    [NSException
                     raise:NSInternalInconsistencyException
                     format:@"Unsupported type for property -[%@ %@]", contextClass, propertyName];
                    return;
            }
            
            class_replaceMethod(contextClass,
                                getterSelector,
                                getterImplementation,
                                [objcType stringByAppendingString:@"@:"].UTF8String);
            class_replaceMethod(contextClass,
                                setterSelector,
                                setterImplementation,
                                [@"v@" stringByAppendingString:objcType].UTF8String);
        }
    }
    free(properties);
}


#pragma mark - Public

#define __JESettings_unimplementedMethod() \
    [NSException \
     raise:NSInternalInconsistencyException \
     format:@"-[%@ %@] not implemented.", [self class], NSStringFromSelector(_cmd)]

- (long long int)integerValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return 0;
}

- (void)setIntegerValue:(long long int)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (unsigned long long int)unsignedIntegerValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return 0;
}

- (void)setUnsignedIntegerValue:(unsigned long long int)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (bool)booleanValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return false;
}

- (void)setBooleanValue:(bool)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (float)floatValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return 0.0f;
}

- (void)setFloatValue:(float)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (double)doubleValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return 0.0;
}

- (void)setDoubleValue:(double)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (NSString *)NSStringValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setNSStringValue:(NSString *)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (NSNumber *)NSNumberValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setNSNumberValue:(NSNumber *)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (NSDate *)NSDateValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setNSDateValue:(NSDate *)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (NSData *)NSDataValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setNSDataValue:(NSData *)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (NSURL *)NSURLValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setNSURLValue:(NSURL *)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (NSUUID *)NSUUIDValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setNSUUIDValue:(NSUUID *)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (id<NSCoding>)NSCodingValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setNSCodingValue:(id<NSCoding>)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (id)idValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return nil;
}

- (void)setIdValue:(id)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (Class)classValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return Nil;
}

- (void)setClassValue:(Class)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (SEL)selectorValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return NULL;
}

- (void)setSelectorValue:(SEL)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (CGPoint)CGPointValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return CGPointZero;
}

- (void)setCGPointValue:(CGPoint)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (CGSize)CGSizeValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return CGSizeZero;
}

- (void)setCGSizeValue:(CGSize)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (CGRect)CGRectValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return CGRectZero;
}

- (void)setCGRectValue:(CGRect)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (CGAffineTransform)CGAffineTransformValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return (CGAffineTransform){ };
}

- (void)setCGAffineTransformValue:(CGAffineTransform)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (CGVector)CGVectorValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return (CGVector){ };
}

- (void)setCGVectorValue:(CGVector)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (UIEdgeInsets)UIEdgeInsetsValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return UIEdgeInsetsZero;
}

- (void)setUIEdgeInsetsValue:(UIEdgeInsets)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (UIOffset)UIOffsetValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return UIOffsetZero;
}

- (void)setUIOffsetValue:(UIOffset)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

- (NSRange)NSRangeValueForKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
    return (NSRange){ };
}

- (void)setNSRangeValue:(NSRange)value forKey:(NSString *)key {
    
    // Subclass override
    __JESettings_unimplementedMethod();
}

@end
