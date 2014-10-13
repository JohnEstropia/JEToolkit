//
//  JEDumpViewController.m
//  JEToolkitDemo
//
//  Created by John Rommel Estropia on 10/13/14.
//  Copyright (c) 2014 John Rommel Estropia. All rights reserved.
//

#import "JEDumpViewController.h"

#import <JEToolkit/JEToolkit.h>


typedef NS_ENUM(NSInteger, JEDumpSamplesSection) {
    
    JEDumpSamplesSectionUsage,
    JEDumpSamplesSectionCPrimitives,
    JEDumpSamplesSectionCStructs,
    JEDumpSamplesSectionCArrays,
    JEDumpSamplesSectionCPointers,
    JEDumpSamplesSectionNSValues,
    JEDumpSamplesSectionCommonObjects,
    JEDumpSamplesSectionCollections,
    JEDumpSamplesSectionMiscObjC,
    
    _JEDumpSamplesSectionCount
};

typedef NS_ENUM(NSInteger, JEDumpUsageRow) {
    
    JEDumpUsageRowDump,
    JEDumpUsageRowWithAnnotation,
    
    _JEDumpUsageRowCount
};

typedef NS_ENUM(NSInteger, JEDumpCPrimitivesRow) {
    
    JEDumpCPrimitivesRowBool,
    JEDumpCPrimitivesRowChar,
    JEDumpCPrimitivesRowUChar,
    JEDumpCPrimitivesRowShort,
    JEDumpCPrimitivesRowUShort,
    JEDumpCPrimitivesRowInt,
    JEDumpCPrimitivesRowUInt,
    JEDumpCPrimitivesRowLong,
    JEDumpCPrimitivesRowULong,
    JEDumpCPrimitivesRowLongLong,
    JEDumpCPrimitivesRowULongLong,
    JEDumpCPrimitivesRowFloat,
    JEDumpCPrimitivesRowDouble,
    JEDumpCPrimitivesRowCString,
    
    _JEDumpCPrimitivesRowCount
};

typedef NS_ENUM(NSInteger, JEDumpCStructsRow) {
    
    JEDumpCStructsRowCGPoint = 0,
    JEDumpCStructsRowCGSize,
    JEDumpCStructsRowCGRect,
    JEDumpCStructsRowCGAffineTransform,
    JEDumpCStructsRowCGVector,
    JEDumpCStructsRowUIEdgeInsets,
    JEDumpCStructsRowUIOffset,
    JEDumpCStructsRowNSRange,
    JEDumpCStructsRowArbitrary,
    
    _JEDumpCStructsRowCount
};

typedef NS_ENUM(NSInteger, JEDumpCArraysRow) {
    
    JEDumpCArraysRowOneDimension = 0,
    JEDumpCArraysRowMultiDimension,
    JEDumpCArraysRowWithAnnotation,
    
    _JEDumpCArraysRowCount
};

typedef NS_ENUM(NSInteger, JEDumpCPointersRow) {
    
    JEDumpCPointersRowPrimitive = 0,
    JEDumpCPointersRowStruct,
    JEDumpCPointersRowArray,
    JEDumpCPointersRowObject,
    JEDumpCPointersRowBlock,
    JEDumpCPointersRowClass,
    JEDumpCPointersRowSelector,
    JEDumpCPointersRowPointer,
    
    _JEDumpCPointersRowCount
};

typedef NS_ENUM(NSInteger, JEDumpNSValuesRow) {
    
    JEDumpNSValuesRowNSNumberBool = 0,
    JEDumpNSValuesRowNSNumberInt,
    JEDumpNSValuesRowNSNumberDouble,
    JEDumpNSValuesRowPrimitive,
    JEDumpNSValuesRowStruct,
    JEDumpNSValuesRowArray,
    JEDumpNSValuesRowObject,
    JEDumpNSValuesRowBlock,
    JEDumpNSValuesRowClass,
    JEDumpNSValuesRowSelector,
    
    _JEDumpNSValuesRowCount
};

typedef NS_ENUM(NSInteger, JEDumpCommonObjectsRow) {
    
    JEDumpCommonObjectsRowNSString = 0,
    JEDumpCommonObjectsRowNSDate,
    JEDumpCommonObjectsRowNSError,
    JEDumpCommonObjectsRowNSException,
    JEDumpCommonObjectsRowUIColor,
    JEDumpCommonObjectsRowUIImage,
    
    _JEDumpCommonObjectsRowCount
};

typedef NS_ENUM(NSInteger, JEDumpCollectionsRow) {
    
    JEDumpCollectionsRowNSArray = 0,
    JEDumpCollectionsRowNSDictionary,
    JEDumpCollectionsRowNSSet,
    JEDumpCollectionsRowNSOrderedSet,
    JEDumpCollectionsRowNSHashTable,
    JEDumpCollectionsRowNSMapTable,
    JEDumpCollectionsRowNSPointerArray,
    
    _JEDumpCollectionsRowCount
};

typedef NS_ENUM(NSInteger, JEDumpMiscObjCRow) {
    
    JEDumpMiscObjCRowClass = 0,
    JEDumpMiscObjCRowSelector,
    JEDumpMiscObjCRowBlock,
    
    _JEDumpMiscObjCRowCount
};


@implementation JEDumpViewController

#pragma mark - BaseSourceCodeSamplerController

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSString *text;
    switch (indexPath.section) {
            
        case JEDumpSamplesSectionUsage: {
            
            switch (indexPath.row) {
                    
                case JEDumpUsageRowDump: text = @"JEDump(someValue);"; break;
                case JEDumpUsageRowWithAnnotation: text = @"JEDump(\"You can also annotate this way\", someValue);"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCPrimitives: {
            
            switch (indexPath.row) {
                    
                case JEDumpCPrimitivesRowBool: text = @"bool"; break;
                case JEDumpCPrimitivesRowChar: text = @"char"; break;
                case JEDumpCPrimitivesRowUChar: text = @"unsigned char"; break;
                case JEDumpCPrimitivesRowShort: text = @"short"; break;
                case JEDumpCPrimitivesRowUShort: text = @"unsigned short"; break;
                case JEDumpCPrimitivesRowInt: text = @"int"; break;
                case JEDumpCPrimitivesRowUInt: text = @"unsigned int"; break;
                case JEDumpCPrimitivesRowLong: text = @"long"; break;
                case JEDumpCPrimitivesRowULong: text = @"unsigned long"; break;
                case JEDumpCPrimitivesRowLongLong: text = @"long long"; break;
                case JEDumpCPrimitivesRowULongLong: text = @"unsigned long long"; break;
                case JEDumpCPrimitivesRowFloat: text = @"float"; break;
                case JEDumpCPrimitivesRowDouble: text = @"double"; break;
                case JEDumpCPrimitivesRowCString: text = @"char *"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCStructs: {
            
            switch (indexPath.row) {
                    
                case JEDumpCStructsRowCGPoint: text = @"CGPoint"; break;
                case JEDumpCStructsRowCGSize: text = @"CGSize"; break;
                case JEDumpCStructsRowCGRect: text = @"CGRect"; break;
                case JEDumpCStructsRowCGAffineTransform: text = @"CGAffineTransform"; break;
                case JEDumpCStructsRowCGVector: text = @"CGVector"; break;
                case JEDumpCStructsRowUIEdgeInsets: text = @"UIEdgeInsets"; break;
                case JEDumpCStructsRowUIOffset: text = @"UIOffset"; break;
                case JEDumpCStructsRowNSRange: text = @"NSRange"; break;
                case JEDumpCStructsRowArbitrary: text = @"Arbitrary"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCArrays: {
            
            switch (indexPath.row) {
                    
                case JEDumpCArraysRowOneDimension: text = @"One-dimension"; break;
                case JEDumpCArraysRowMultiDimension: text = @"Multi-dimension"; break;
                case JEDumpCArraysRowWithAnnotation: text = @"JEDump(\"When annotating C arrays, use the array address instead\", &cArray);"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCPointers: {
            
            switch (indexPath.row) {
                    
                case JEDumpCPointersRowPrimitive: text = @"int *"; break;
                case JEDumpCPointersRowStruct: text = @"CGPoint *"; break;
                case JEDumpCPointersRowArray: text = @"int[3] *"; break;
                case JEDumpCPointersRowObject: text = @"NSError **"; break;
                case JEDumpCPointersRowBlock: text = @"void(^)(void) *"; break;
                case JEDumpCPointersRowClass: text = @"Class *"; break;
                case JEDumpCPointersRowSelector: text = @"SEL *"; break;
                case JEDumpCPointersRowPointer: text = @"void **"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionNSValues: {
            
            switch (indexPath.row) {
                    
                case JEDumpNSValuesRowNSNumberBool: text = @"NSNumber (bool)"; break;
                case JEDumpNSValuesRowNSNumberInt: text = @"NSNumber (int)"; break;
                case JEDumpNSValuesRowNSNumberDouble: text = @"NSNumber (double)"; break;
                case JEDumpNSValuesRowPrimitive: text = @"NSValue (objCType: int)"; break;
                case JEDumpNSValuesRowStruct: text = @"NSValue (objCType: CGPoint)"; break;
                case JEDumpNSValuesRowArray: text = @"NSValue (objCType: int[3])"; break;
                case JEDumpNSValuesRowObject: text = @"NSValue (objCType: NSError *)"; break;
                case JEDumpNSValuesRowBlock: text = @"NSValue (objCType: void(^)(void))"; break;
                case JEDumpNSValuesRowClass: text = @"NSValue (objCType: Class)"; break;
                case JEDumpNSValuesRowSelector: text = @"NSValue (objCType: SEL)"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCommonObjects: {
            
            switch (indexPath.row) {
                    
                case JEDumpCommonObjectsRowNSString: text = @"NSString"; break;
                case JEDumpCommonObjectsRowNSDate: text = @"NSDate"; break;
                case JEDumpCommonObjectsRowNSError: text = @"NSError"; break;
                case JEDumpCommonObjectsRowNSException: text = @"NSException"; break;
                case JEDumpCommonObjectsRowUIColor: text = @"UIColor"; break;
                case JEDumpCommonObjectsRowUIImage: text = @"UIImage"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCollections: {
            
            switch (indexPath.row) {
                    
                case JEDumpCollectionsRowNSArray: text = @"NSArray"; break;
                case JEDumpCollectionsRowNSDictionary: text = @"NSDictionary"; break;
                case JEDumpCollectionsRowNSSet: text = @"NSSet"; break;
                case JEDumpCollectionsRowNSOrderedSet: text = @"NSOrderedSet"; break;
                case JEDumpCollectionsRowNSHashTable: text = @"NSHashTable"; break;
                case JEDumpCollectionsRowNSMapTable: text = @"NSMapTable"; break;
                case JEDumpCollectionsRowNSPointerArray: text = @"NSPointerArray"; break;
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionMiscObjC: {
            
            switch (indexPath.row) {
                    
                case JEDumpMiscObjCRowClass: text = @"Class"; break;
                case JEDumpMiscObjCRowSelector: text = @"SEL"; break;
                case JEDumpMiscObjCRowBlock: text = @"int (^)(int, NSError *)"; break;
                default: break;
            }
            break;
        }
        default: break;
    }
    cell.textLabel.text = text;
}

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
            
        case JEDumpSamplesSectionUsage: {
            
            switch (indexPath.row) {
                    
                case JEDumpUsageRowDump: {
                    
                    NSNumber *someValue = @42;
                    JEDump(someValue);
                    break;
                }
                case JEDumpUsageRowWithAnnotation: {
                    
                    NSNumber *someValue = @42;
                    JEDump("You can also annotate this way", someValue);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCPrimitives: {
            
            switch (indexPath.row) {
                    
                case JEDumpCPrimitivesRowBool: {
                    
                    bool boolValue = true;
                    JEDump(boolValue);
                    break;
                }
                case JEDumpCPrimitivesRowChar: {
                    
                    char charValue = 'A';
                    JEDump(charValue);
                    break;
                }
                case JEDumpCPrimitivesRowUChar: {
                    
                    unsigned char ucharValue = UCHAR_MAX;
                    JEDump(ucharValue);
                    break;
                }
                case JEDumpCPrimitivesRowShort: {
                    
                    short shortValue = INT16_MIN;
                    JEDump(shortValue);
                    break;
                }
                case JEDumpCPrimitivesRowUShort: {
                    
                    unsigned short ushortValue = UINT16_MAX;
                    JEDump(ushortValue);
                    break;
                }
                case JEDumpCPrimitivesRowInt: {
                    
                    int intValue = INT_MIN;
                    JEDump(intValue);
                    break;
                }
                case JEDumpCPrimitivesRowUInt: {
                    
                    unsigned int uintValue = UINT_MAX;
                    JEDump(uintValue);
                    break;
                }
                case JEDumpCPrimitivesRowLong: {
                    
                    long longValue = LONG_MIN;
                    JEDump(longValue);
                    break;
                }
                case JEDumpCPrimitivesRowULong: {
                    
                    unsigned long ulongValue = ULONG_MAX;
                    JEDump(ulongValue);
                    break;
                }
                case JEDumpCPrimitivesRowLongLong: {
                    
                    long long longlongValue = LONG_LONG_MIN;
                    JEDump(longlongValue);
                    break;
                }
                case JEDumpCPrimitivesRowULongLong: {
                    
                    unsigned long long ulonglongValue = ULONG_LONG_MAX;
                    JEDump(ulonglongValue);
                    break;
                }
                case JEDumpCPrimitivesRowFloat: {
                    
                    float floatValue = FLT_MIN;
                    JEDump(floatValue);
                    break;
                }
                case JEDumpCPrimitivesRowDouble: {
                    
                    double doubleValue = DBL_MAX;
                    JEDump(doubleValue);
                    break;
                }
                case JEDumpCPrimitivesRowCString: {
                    
                    char *cstringValue = "string";
                    JEDump(cstringValue);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCStructs: {
            
            switch (indexPath.row) {
                    
                case JEDumpCStructsRowCGPoint: {
                    
                    CGPoint pointValue = CGPointMake(42.0f, 42.0f);
                    JEDump(pointValue);
                    break;
                }
                case JEDumpCStructsRowCGSize: {
                    
                    CGSize sizeValue = CGSizeMake(42.0f, 42.0f);
                    JEDump(sizeValue);
                    break;
                }
                case JEDumpCStructsRowCGRect: {
                    
                    CGRect rectValue = CGRectMake(0.0f, 0.0f, 42.0f, 42.0f);
                    JEDump(rectValue);
                    break;
                }
                case JEDumpCStructsRowCGAffineTransform: {
                    
                    CGAffineTransform transformValue = CGAffineTransformIdentity;
                    JEDump(transformValue);
                    break;
                }
                case JEDumpCStructsRowCGVector: {
                    
                    CGVector vectorValue = CGVectorMake(42.0f, 42.0f);
                    JEDump(vectorValue);
                    break;
                }
                case JEDumpCStructsRowUIEdgeInsets: {
                    
                    UIEdgeInsets insetsValue = UIEdgeInsetsMake(42.0f, 0.0f, 42.0f, 0.0f);
                    JEDump(insetsValue);
                    break;
                }
                case JEDumpCStructsRowUIOffset: {
                    
                    UIOffset offsetValue = UIOffsetMake(0.0f, 42.0f);
                    JEDump(offsetValue);
                    break;
                }
                case JEDumpCStructsRowNSRange: {
                    
                    NSRange rangeValue = NSMakeRange(0, 42);
                    JEDump(rangeValue);
                    break;
                }
                case JEDumpCStructsRowArbitrary: {
                    
                    typedef struct ArbitraryStruct { int a; int b; } ArbitraryStruct;
                    ArbitraryStruct arbitraryValue = (ArbitraryStruct){ .a = 0, .b = 1 };
                    JEDump(arbitraryValue);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCArrays: {
            
            switch (indexPath.row) {
                    
                case JEDumpCArraysRowOneDimension: {
                    
                    CGPoint oneDimensionArray[3] = {};
                    for(int i = 0; i < 3; ++i) {
                        
                        oneDimensionArray[i] = CGPointMake(0, i);
                    }
                    JEDump(oneDimensionArray);
                    break;
                }
                case JEDumpCArraysRowMultiDimension: {
                    
                    int multiDimensionArray[2][3] = {{1, 2, 3}, {4, 5, 6}};
                    JEDump(multiDimensionArray);
                    break;
                }
                case JEDumpCArraysRowWithAnnotation: {
                    
                    int cArray[2][3] = {{1, 2, 3}, {4, 5, 6}};
                    JEDump("When annotating C arrays, use the array address instead", &cArray);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCPointers: {
            
            switch (indexPath.row) {
                    
                case JEDumpCPointersRowPrimitive: {
                    
                    int value = 42;
                    typeof(value) *intPointerValue = &value;
                    JEDump(intPointerValue);
                    break;
                }
                case JEDumpCPointersRowStruct: {
                    
                    CGPoint value = CGPointZero;
                    typeof(value) *pointPointerValue = &value;
                    JEDump(pointPointerValue);
                    break;
                }
                case JEDumpCPointersRowArray: {
                    
                    int value[3] = { 1, 2, 3 };
                    typeof(value) *carrayPointerValue = &value;
                    JEDump(carrayPointerValue);
                    break;
                }
                case JEDumpCPointersRowObject: {
                    
                    NSError *value = [NSError
                                      errorWithDomain:NSCocoaErrorDomain
                                      code:NSFileNoSuchFileError
                                      userInfo:nil];
                    typeof(value) *objectPointerValue = &value;
                    JEDump(objectPointerValue);
                    break;
                }
                case JEDumpCPointersRowBlock: {
                    
                    void (^value)(void) = ^{};
                    typeof(value) *blockPointerValue = &value;
                    JEDump(blockPointerValue);
                    break;
                }
                case JEDumpCPointersRowClass: {
                    
                    Class value = [UIView class];
                    typeof(value) *classPointerValue = &value;
                    JEDump(classPointerValue);
                    break;
                }
                case JEDumpCPointersRowSelector: {
                    
                    SEL value = @selector(tableView:cellForRowAtIndexPath:);
                    typeof(value) *selectorPointerValue = &value;
                    JEDump(selectorPointerValue);
                    break;
                }
                case JEDumpCPointersRowPointer: {
                    
                    void *value = NULL;
                    typeof(value) *pointerPointerValue = &value;
                    JEDump(pointerPointerValue);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionNSValues: {
            
            switch (indexPath.row) {
                    
                case JEDumpNSValuesRowNSNumberBool: {
                    
                    NSNumber *numberBoolValue = @YES;
                    JEDump(numberBoolValue);
                    break;
                }
                case JEDumpNSValuesRowNSNumberInt: {
                    
                    NSNumber *numberIntValue = @((int)42);
                    JEDump(numberIntValue);
                    break;
                }
                case JEDumpNSValuesRowNSNumberDouble: {
                    
                    NSNumber *numberDoubleValue = @((double)M_PI);
                    JEDump(numberDoubleValue);
                    break;
                }
                case JEDumpNSValuesRowPrimitive: {
                    
                    int value = 42;
                    NSValue *valueWrappedIntValue = [NSValue valueWithBytes:&value objCType:@encode(typeof(value))];
                    JEDump(valueWrappedIntValue);
                    break;
                }
                case JEDumpNSValuesRowStruct: {
                    
                    CGPoint value = CGPointZero;
                    NSValue *valueWrappedPointValue = [NSValue valueWithBytes:&value objCType:@encode(typeof(value))];
                    JEDump(valueWrappedPointValue);
                    break;
                }
                case JEDumpNSValuesRowArray: {
                    
                    int value[3] = { 1, 2, 3 };
                    NSValue *valueWrappedCArrayValue = [NSValue valueWithBytes:&value objCType:@encode(typeof(value))];
                    JEDump(valueWrappedCArrayValue);
                    break;
                }
                case JEDumpNSValuesRowObject: {
                    
                    NSError *value = [NSError
                                      errorWithDomain:NSCocoaErrorDomain
                                      code:NSFileNoSuchFileError
                                      userInfo:nil];
                    NSValue *valueWrappedObjectValue = [NSValue valueWithBytes:&value objCType:@encode(typeof(value))];
                    JEDump(valueWrappedObjectValue);
                    break;
                }
                case JEDumpNSValuesRowBlock: {
                    
                    void (^value)(void) = ^{};
                    NSValue *valueWrappedBlockValue = [NSValue valueWithBytes:&value objCType:@encode(typeof(value))];
                    JEDump(valueWrappedBlockValue);
                    break;
                }
                case JEDumpNSValuesRowClass: {
                    
                    Class value = [UIView class];
                    NSValue *valueWrappedClassValue = [NSValue valueWithBytes:&value objCType:@encode(typeof(value))];
                    JEDump(valueWrappedClassValue);
                    break;
                }
                case JEDumpNSValuesRowSelector: {
                    
                    SEL value = @selector(tableView:cellForRowAtIndexPath:);
                    NSValue *valueWrappedSelectorValue = [NSValue valueWithBytes:&value objCType:@encode(typeof(value))];
                    JEDump(valueWrappedSelectorValue);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCommonObjects: {
            
            switch (indexPath.row) {
                    
                case JEDumpCommonObjectsRowNSString: {
                    
                    id mutableStringValue = [NSMutableString stringWithString:@"escaping\npreserved! 😎✅"];
                    JEDump(mutableStringValue);
                    break;
                }
                case JEDumpCommonObjectsRowNSDate: {
                    
                    id dateValue = [NSDate new];
                    JEDump(dateValue);
                    break;
                }
                case JEDumpCommonObjectsRowNSError: {
                    
                    id errorValue = [NSError
                                     errorWithDomain:NSCocoaErrorDomain
                                     code:NSFileNoSuchFileError
                                     userInfo:nil];
                    JEDump(errorValue);
                    break;
                }
                case JEDumpCommonObjectsRowNSException: {
                    
                    @try {
                        
                        [[NSException
                          exceptionWithName:@"JEToolkitDemoException"
                          reason:@"This exception is just a test"
                          userInfo:@{ @"stringKey": @"string",
                                      @"numberKey": @42,
                                      @"dateKey": [NSDate new] }] raise];
                        
                    }
                    @catch (NSException *exception) {
                        
                        JEDump(exception);
                    }
                    break;
                }
                case JEDumpCommonObjectsRowUIColor: {
                    
                    id colorValue = [UIColor blueColor];
                    JEDump(colorValue);
                    break;
                }
                case JEDumpCommonObjectsRowUIImage: {
                    
                    id imageValue = [UIImage
                                     imageFromColor:[UIColor blueColor]
                                     size:CGSizeMake(360.0f, 480.0f)];
                    JEDump(imageValue);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionCollections: {
            
            switch (indexPath.row) {
                    
                case JEDumpCollectionsRowNSArray: {
                    
                    id arrayValue = @[ @"string", @42, [NSDate new], [NSNull null], [^{} copy],
                                       @[@1, @2, @3],
                                       @{ @"key1": @1, @"key2": @2, @"key3": @3} ];
                    JEDump(arrayValue);
                    break;
                }
                case JEDumpCollectionsRowNSDictionary: {
                    
                    id dictionaryValue = @{ @"stringKey": @"string",
                                            @"numberKey": @42,
                                            @"dateKey": [NSDate new],
                                            @"nullKey": [NSNull null],
                                            @"blockKey": [^{} copy],
                                            @"arrayKey": @[@1, @2, @3],
                                            @"dictionaryKey": @{ @"key1": @1, @"key2": @2, @"key3": @3 } };
                    JEDump(dictionaryValue);
                    break;
                }
                case JEDumpCollectionsRowNSSet: {
                    
                    id setValue = [NSSet setWithObjects:@1, @2, @3, nil];
                    JEDump(setValue);
                    break;
                }
                case JEDumpCollectionsRowNSOrderedSet: {
                    
                    id orderedSetValue = [NSOrderedSet orderedSetWithObjects:@1, @2, @3, nil];
                    JEDump(orderedSetValue);
                    break;
                }
                case JEDumpCollectionsRowNSHashTable: {
                    
                    NSArray *array = @[@1, @2, @3];
                    NSHashTable *hashTableValue = [NSHashTable weakObjectsHashTable];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        [hashTableValue addObject:obj];
                        
                    }];
                    JEDump(hashTableValue);
                    break;
                }
                case JEDumpCollectionsRowNSMapTable: {
                    
                    NSMapTable *mapTableValue = [NSMapTable strongToStrongObjectsMapTable];
                    [mapTableValue setObject:@"one" forKey:@1];
                    [mapTableValue setObject:@"two" forKey:@2];
                    [mapTableValue setObject:@"three" forKey:@3];
                    JEDump(mapTableValue);
                    break;
                }
                case JEDumpCollectionsRowNSPointerArray: {
                    
                    NSArray *array = @[@1, @2, @3];
                    NSPointerArray *pointerArrayValue = [NSPointerArray weakObjectsPointerArray];
                    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        
                        [pointerArrayValue addPointer:(__bridge void *)(obj)];
                        
                    }];
                    JEDump(pointerArrayValue);
                    break;
                }
                default: break;
            }
            break;
        }
        case JEDumpSamplesSectionMiscObjC: {
            
            switch (indexPath.row) {
                    
                case JEDumpMiscObjCRowClass: {
                    
                    Class classValue = [UIView class];
                    JEDump(classValue);
                    break;
                }
                case JEDumpMiscObjCRowSelector: {
                    
                    SEL selectorValue = @selector(tableView:cellForRowAtIndexPath:);
                    JEDump(selectorValue);
                    break;
                }
                case JEDumpMiscObjCRowBlock: {
                    
                    int (^blockValue)(int, NSError *) = ^int(int i, NSError *error){ return 0; };
                    JEDump(blockValue);
                    break;
                }
                default: break;
            }
            break;
        }
        default: break;
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _JEDumpSamplesSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
            
        case JEDumpSamplesSectionUsage: return _JEDumpUsageRowCount;
        case JEDumpSamplesSectionCPrimitives: return _JEDumpCPrimitivesRowCount;
        case JEDumpSamplesSectionCStructs: return _JEDumpCStructsRowCount;
        case JEDumpSamplesSectionCArrays: return _JEDumpCArraysRowCount;
        case JEDumpSamplesSectionCPointers: return _JEDumpCPointersRowCount;
        case JEDumpSamplesSectionNSValues: return _JEDumpNSValuesRowCount;
        case JEDumpSamplesSectionCommonObjects: return _JEDumpCommonObjectsRowCount;
        case JEDumpSamplesSectionCollections: return _JEDumpCollectionsRowCount;
        case JEDumpSamplesSectionMiscObjC: return _JEDumpMiscObjCRowCount;
        default: return 0;
    }
}


#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    switch (section) {
            
        case JEDumpSamplesSectionUsage: return @"Sample Usage";
        case JEDumpSamplesSectionCPrimitives: return @"C Primitives";
        case JEDumpSamplesSectionCStructs: return @"C Structs";
        case JEDumpSamplesSectionCArrays: return @"C Arrays";
        case JEDumpSamplesSectionCPointers: return @"C Pointers";
        case JEDumpSamplesSectionNSValues: return @"NSValues";
        case JEDumpSamplesSectionCommonObjects: return @"Common Objects";
        case JEDumpSamplesSectionCollections: return @"Collection Objects";
        case JEDumpSamplesSectionMiscObjC: return @"Other Objective-C Types";
        default: return nil;
    }
}

@end
