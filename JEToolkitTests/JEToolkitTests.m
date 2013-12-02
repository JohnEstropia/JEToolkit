//
//  JEToolkitTests.m
//  JEToolkitTests
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <float.h>

#import "JEToolkit.h"
#import "JEOrderedDictionary.h"


@interface JEToolkitTests : XCTestCase

@end


@implementation JEToolkitTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDumps
{
    [JEDebugging setFileLogLevelMask:JELogLevelAll];
    
    JEDump(nil, 100);
    int oneHundred = 100;
    JEDump(nil, oneHundred);
    JEDump(nil, &oneHundred);
    JEDump(nil, [NSValue valueWithBytes:&oneHundred objCType:@encode(typeof(oneHundred))]);
    JEDump(nil, (50 + 50));
    
    JEDump(nil, 12345.12345f);
    JEDump(nil, [NSNumber numberWithFloat:12345.12345f]);
    JEDump(nil, 12345678901234567890.0f);
    JEDump(nil, [NSNumber numberWithFloat:12345678901234567890.0f]);
    JEDump(nil, 12345678901234567890.0);
    JEDump(nil, [NSNumber numberWithDouble:12345678901234567890.0]);
    JEDump(nil, M_PI);
    JEDump(nil, [NSNumber numberWithDouble:M_PI]);
    JEDump(nil, NSIntegerMax);
    JEDump(nil, NSIntegerMin);
    JEDump(nil, CGFLOAT_MAX);
    JEDump(nil, [NSNumber numberWithFloat:CGFLOAT_MAX]);
    JEDump(nil, CGFLOAT_MIN);
    JEDump(nil, [NSNumber numberWithFloat:CGFLOAT_MIN]);
    JEDump(nil, DBL_MAX);
    JEDump(nil, [NSNumber numberWithDouble:DBL_MAX]);
    JEDump(nil, DBL_MIN);
    JEDump(nil, [NSNumber numberWithDouble:DBL_MIN]);
    
    JEDump(nil, "cstring");
    char *cstringPtr = NULL;
    JEDump(nil, cstringPtr);
    JEDump(nil, &cstringPtr);
    JEDump(nil, [NSValue valueWithBytes:&cstringPtr objCType:@encode(typeof(cstringPtr))]);
    cstringPtr = "cstring";
    JEDump(nil, cstringPtr);
    JEDump(nil, &cstringPtr);
    char cstringArray[7] = "cstring";
    JEDumpArray(nil, cstringArray);
    JEDump(nil, &cstringArray);
    JEDump(nil, [NSValue valueWithBytes:cstringArray objCType:@encode(typeof(cstringArray))]);
    char asciiArray[CHAR_MAX + 1] = {};
    for(int i = 0; i <= CHAR_MAX; ++i)
    {
        asciiArray[i] = i;
    }
    JEDumpArray(nil, asciiArray);

    JEDump(nil, _cmd);
    JEDump(nil, @selector(viewDidAppear:));
    SEL selector = NULL;
    JEDump(nil, selector);
    JEDump(nil, &selector);
    JEDump(nil, [NSValue valueWithBytes:&selector objCType:@encode(typeof(selector))]);
    selector = _cmd;
    JEDump(nil, selector);
    JEDump(nil, &selector);
    JEDump(nil, [NSValue valueWithBytes:&selector objCType:@encode(typeof(selector))]);
    
    
    JEDump(nil, [UIView new]);
    JEDump(nil, @"日本語😈");
    UIView * view = nil;
    JEDump(nil, view);
    JEDump(nil, &view);
    JEDump(nil, [NSValue valueWithBytes:&view objCType:@encode(typeof(view))]);
    view = [UIView new];
    JEDump(nil, view);
    JEDump(nil, &view);
    JEDump(nil, [NSValue valueWithBytes:&view objCType:@encode(typeof(view))]);
    
    NSValue *value = [NSValue valueWithNonretainedObject:view];
    JEDump(nil, value);
    value = [NSValue valueWithPointer:CGColorCreate];
    JEDump(nil, value);
    
    JEDump(nil, [view class]);
    JEDump(nil, [UIView class]);
    Class class = Nil;
    JEDump(nil, class);
    JEDump(nil, &class);
    JEDump(nil, [NSValue valueWithBytes:&class objCType:@encode(typeof(class))]);
    class = [UIView class];
    JEDump(nil, class);
    JEDump(nil, &class);
    JEDump(nil, [NSValue valueWithBytes:&class objCType:@encode(typeof(class))]);
    
    NSError *error = nil;
    JEDump(nil, [[NSFileManager defaultManager]
            moveItemAtPath:@"testdir"
            toPath:@"testdir"
            error:&error]);
    JEDump(nil, error);
    JEDump(nil, [error userInfo]);
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@12] = @"cccc";
    dictionary[@34] = @"gggg";
    dictionary[@56] = @"iiii";
    dictionary[@"j"] = @"jjjj";
    dictionary[@"three"] = @{ @"threeone" : @31, @"threetwo" : @"three-two" };
    dictionary[@"e"] = @"eeee";
    dictionary[@"a"] = @1;
    dictionary[@"f"] = @"ffff";
    dictionary[@{ @"oneone" : @11 }] = @{ @"oneone" : @11 };
    dictionary[@"d"] = @"dddd";
    dictionary[@"b"] = @"bbbb";
    dictionary[@"h"] = @"hhhh";
    JEDump(nil, dictionary);
    
    JEDump(nil, [dictionary allKeys]);
    JEDump(nil, [NSOrderedSet orderedSetWithArray:[dictionary allKeys]]);
    JEDump(nil, [NSSet setWithArray:[dictionary allValues]]);
    
    
    NSMapTable *mapTable = [NSMapTable strongToWeakObjectsMapTable];
    NSHashTable *hashTable = [NSHashTable weakObjectsHashTable];
    NSPointerArray *pointerArray = [NSPointerArray weakObjectsPointerArray];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        [mapTable setObject:obj forKey:key];
        [hashTable addObject:key];
        [pointerArray addPointer:(__bridge void *)(obj)];
        
    }];
    JEDump(nil, mapTable);
    JEDump(nil, hashTable);
    JEDump(nil, pointerArray);
    
    JEDump(nil, CGRectZero);
    
    JEDump(nil, (CGPoint){ 1.999, 2.999 });
    JEDump(nil, (CGSize){ 1.999, 2.999 });
    JEDump(nil, (CGRect){ {1.999, 2.999 }, { 3.999, 4.999 }});
    JEDump(nil, (CGAffineTransform){ 1.999, 2.999, 3.999, 4.999, 5.999, 6.999 });
    JEDump(nil, (UIEdgeInsets){ 1.999, 2.999, 3.999, 4.999 });
    JEDump(nil, (UIOffset){ 1.999, 2.999 });
    JEDump(nil, (NSRange){ 1, 2 });
    JEDump(nil, (CLLocationCoordinate2D){ 1.999, 2.999 });
    JEDump(nil, (MKCoordinateSpan){ 1.999, 2.999 });
    JEDump(nil, (MKCoordinateRegion){ { 1.999, 2.999 }, { 3.999, 4.999 } });
    JEDump(nil, (MKMapPoint){ 1.999, 2.999 });
    JEDump(nil, (MKMapSize){ 1.999, 2.999 });
    JEDump(nil, (MKMapRect){ { 1.999, 2.999 }, { 3.999, 4.999 } });
    struct { int i1; int i2; int i3; } unnamedStruct;
    JEDump(nil, unnamedStruct);
    
    CGRect rect = (CGRect){{1, 2}, {3, 4}};
    JEDump(nil, rect);
    JEDump(nil, &rect);
    JEDump(nil, [NSValue valueWithBytes:&rect objCType:@encode(typeof(rect))]);
    JEDumpArray(nil,
                (CGRect [3]){(CGRect){ {1.999, 2.999 }, { 3.999, 4.999 }}, (CGRect){ {1.999, 2.999 }, { 3.999, 4.999 }}, (CGRect){ {1.999, 2.999 }, { 3.999, 4.999 }}});
    
    JEDump(nil, &CGImageCreate);
    
    int intArray[2][3] = {{1, 2, 3}, {4, 5, 6}};
    JEDumpArray(nil, intArray);
    JEDump(nil, &intArray);
    JEDump(nil, [NSValue valueWithBytes:intArray objCType:@encode(typeof(intArray))]);
    
    JEDump(nil, ^(int intParam, id idParam, CGRect rectParam, NSError ** outErrorParam){ return intParam + 100; });
    int (^block)(int intParam) = NULL;
    JEDump(nil, block);
    JEDump(nil, &block);
    JEDump(nil, [NSValue valueWithBytes:&block objCType:@encode(typeof(block))]);
    block = ^(int intParam){ return intParam + 100; };
    JEDump(nil, block);
    JEDump(nil, &block);
    JEDump(nil, [NSValue valueWithBytes:&block objCType:@encode(typeof(block))]);
    dispatch_block_t voidBlock = ^{ };
    JEDump(nil, voidBlock);
    
    JEDump(nil, FLT_DIG);
    JEDump(nil, DBL_DIG);
    JEDump(nil, LDBL_DIG);
    JEDump(nil, DECIMAL_DIG);
    
    long double longDouble = 11111.9999888888888888;
    JEDump(nil, longDouble);
    
    JEDump(nil, 0.12345f);
    JEDump(nil, [[NSNumber numberWithFloat:0.12345f] stringValue]);
    JEDump(nil, 0.123456f);
    JEDump(nil, [[NSNumber numberWithFloat:0.123456f] stringValue]);
    JEDump(nil, 0.1234567f);
    JEDump(nil, [[NSNumber numberWithFloat:0.1234567f] stringValue]);
    JEDump(nil, 0.12345678f);
    JEDump(nil, [[NSNumber numberWithFloat:0.12345678f] stringValue]);
    JEDump(nil, 0.123456789f);
    JEDump(nil, [[NSNumber numberWithFloat:0.123456789f] stringValue]);
    JEDump(nil, 0.1234567899f);
    JEDump(nil, [[NSNumber numberWithFloat:0.1234567899f] stringValue]);
    JEDump(nil, 0.12345678991f);
    JEDump(nil, [[NSNumber numberWithFloat:0.12345678991f] stringValue]);
    JEDump(nil, 0.123456789912f);
    JEDump(nil, [[NSNumber numberWithFloat:0.123456789912f] stringValue]);
    JEDump(nil, 123.123f);
    JEDump(nil, [[NSNumber numberWithFloat:123.123f] stringValue]);
    JEDump(nil, 1234.1234f);
    JEDump(nil, [[NSNumber numberWithFloat:1234.1234f] stringValue]);
    JEDump(nil, 12345.12345f);
    JEDump(nil, [[NSNumber numberWithFloat:12345.12345f] stringValue]);
    JEDump(nil, 123456.123456f);
    JEDump(nil, [[NSNumber numberWithFloat:123456.123456f] stringValue]);
    JEDump(nil, 1234567.1234567f);
    JEDump(nil, [[NSNumber numberWithFloat:1234567.1234567f] stringValue]);
    JEDump(nil, 12345678.12345678f);
    JEDump(nil, [[NSNumber numberWithFloat:12345678.12345678f] stringValue]);
    JEDump(nil, 123456789.123456789f);
    JEDump(nil, [[NSNumber numberWithFloat:123456789.123456789f] stringValue]);
    JEDump(nil, 1234567899.1234567899f);
    JEDump(nil, [[NSNumber numberWithFloat:1234567899.1234567899f] stringValue]);
    
    JEDump(nil, 0.1234567);
    JEDump(nil, [[NSNumber numberWithDouble:0.1234567] stringValue]);
    JEDump(nil, 0.12345678);
    JEDump(nil, 0.123456789);
    JEDump(nil, 0.1234567899);
    JEDump(nil, 0.12345678991);
    JEDump(nil, 0.123456789912);
    JEDump(nil, 0.1234567899123);
    JEDump(nil, 0.12345678991234);
    JEDump(nil, 0.123456789912345);
    JEDump(nil, 0.1234567899123456);
    JEDump(nil, 0.12345678991234567);
    JEDump(nil, 0.123456789912345678);
    JEDump(nil, 0.1234567899123456789);
    JEDump(nil, 0.12345678991234567899);
    JEDump(nil, 0.123456789912345678991);
    JEDump(nil, [[NSNumber numberWithDouble:0.123456789912345678991] stringValue]);
    JEDump(nil, 123456.123456);
    JEDump(nil, [[NSNumber numberWithDouble:123456.123456] stringValue]);
    JEDump(nil, 1234567.1234567);
    JEDump(nil, 12345678.12345678);
    JEDump(nil, 123456789.123456789);
    JEDump(nil, 1234567899.1234567899);
    JEDump(nil, 12345678991.12345678991);
    JEDump(nil, 123456789912.123456789912);
    JEDump(nil, 1234567899123.1234567899123);
    JEDump(nil, 12345678991234.12345678991234);
    JEDump(nil, 123456789912345.123456789912345);
    JEDump(nil, 1234567899123456.1234567899123456);
    JEDump(nil, 12345678991234567.12345678991234567);
    JEDump(nil, 123456789912345678.123456789912345678);
    JEDump(nil, 1234567899123456789.1234567899123456789);
    JEDump(nil, 12345678991234567899.0);
    JEDump(nil, [[NSNumber numberWithDouble:12345678991234567899.0] stringValue]);
    
    JEDump(nil, 0.123456789912l);
    JEDump(nil, 0.1234567899123l);
    JEDump(nil, 0.12345678991234l);
    JEDump(nil, 0.123456789912345l);
    JEDump(nil, 0.1234567899123456l);
    JEDump(nil, 0.12345678991234567l);
    JEDump(nil, 0.123456789912345678l);
    JEDump(nil, 0.1234567899123456789l);
    JEDump(nil, 0.12345678991234567899l);
    JEDump(nil, 0.123456789912345678991l);
    JEDump(nil, 0.1234567899123456789912l);
    JEDump(nil, 0.12345678991234567899123l);
    JEDump(nil, 0.123456789912345678991234l);
    JEDump(nil, 123456.123456l);
    JEDump(nil, 1234567.1234567l);
    JEDump(nil, 12345678.12345678l);
    JEDump(nil, 123456789.123456789l);
    JEDump(nil, 1234567899.1234567899l);
    JEDump(nil, 12345678991.12345678991l);
    JEDump(nil, 123456789912.123456789912l);
    JEDump(nil, 1234567899123.1234567899123l);
    JEDump(nil, 12345678991234.12345678991234l);
    JEDump(nil, 123456789912345.123456789912345l);
    JEDump(nil, 1234567899123456.1234567899123456l);
    JEDump(nil, 12345678991234567.1234567l);
    JEDump(nil, 123456789912345678.12345678l);
    JEDump(nil, 1234567899123456789.123456789l);
    JEDump(nil, 12345678991234567899.1234567899l);
    JEDump(nil, 123456789912345678991.12345678991l);
    JEDump(nil, 1234567899123456789912.123456789912l);
    JEDump(nil, 12345678991234567899123.1234567899123l);
    
    JEDump(nil, (CGColorRef)NULL);
    JEDump(nil, [UIColor clearColor].CGColor);
    JEDump(nil, CFGetTypeID([UIColor clearColor].CGColor));
    
    @try {
        
        [[NSException
          exceptionWithName:@"Test Exception"
          reason:@"This exception was raised to test exception logging"
          userInfo:dictionary] raise];
    }
    @catch (NSException *exception) {
        
        JEDump(nil, exception);
    }
    
    JEOrderedDictionary *orderedDictionary = [[JEOrderedDictionary alloc] init];
    orderedDictionary[@"500"] = @5,000;
    orderedDictionary[@"200"] = @NO;
    orderedDictionary[@3000] = @"300";
    orderedDictionary[@"100"] = @1,000;
    orderedDictionary[@"000"] = @0;
    JEDump(nil, orderedDictionary);
    
    orderedDictionary[@"500"] = @YES;
    JEDump(nil, orderedDictionary);
    
    JEDump(nil, [NSNumber numberWithBool:YES]);
    JEDump(nil, [NSNumber numberWithBool:NO]);
    JEDump(nil, [NSNumber numberWithChar:YES]);
    JEDump(nil, [NSNumber numberWithChar:NO]);
    JEDump(nil, @YES);
    JEDump(nil, @NO);
    JEDump(nil, @([orderedDictionary count] == 5));
    JEDump(nil, @([orderedDictionary count] < 5));
    JEDump(nil, @((BOOL)([orderedDictionary count] == 5)));
    JEDump(nil, @((BOOL)([orderedDictionary count] < 5)));
    
    NSString *string = @"string";
    id idArray[] = { string, string, string };
    JEDumpArray(nil, idArray);
    
    JEDump(nil, [NSNull null]);
    
    JELog(@"Trace No Parameters");
    JELogNotice(@"Log No Parameters");
    JELogAlert(@"Alert No Parameters");
    
    JELog(@"Trace Many Parameters: %@, %d, %f", @"yo", 10, 20.4f);
    JELogNotice(@"Log Many Parameters: %@, %d, %f", @"yo", 10, 20.4f);
    JELogAlert(@"Alert Many Parameters: %@, %d, %f", @"yo", 10, 20.4f);
    
    dispatch_queue_t queue = dispatch_queue_create("TestQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_sync(queue, ^{
        
        JELogLevel((1 << 5), @"Named queue");
        
    });
    
    queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_sync(queue, ^{
        
        JELogLevel((1 << 5), @"Unnamed queue");
        
    });
}

JESynthesizeObject(id, synthesizedId, setSynthesizedId, JESynthesizeRetainNonatomic);
JESynthesizeObject(void(^)(void), synthesizedBlock, setSynthesizedBlock, JESynthesizeCopyNonatomic);
JESynthesizeObject(id, synthesizedAssign, setSynthesizedAssign, JESynthesizeAssign);
JESynthesizeScalar(CGRect, synthesizedRect, setSynthesizedRect);

- (void)testSynthesized
{
    JEDump(@"Before assignment", self.synthesizedId);
    self.synthesizedId = @"test";
    JEDump(@"After assignment", self.synthesizedId);
    
    JEDump(@"Before assignment", self.synthesizedBlock);
    self.synthesizedBlock = ^{ };
    JEDump(@"After assignment", self.synthesizedBlock);
    
    JEDump(@"Before assignment", self.synthesizedAssign);
    self.synthesizedAssign = self;
    JEDump(@"After assignment", self.synthesizedAssign);
    
    JEDump(@"Before assignment", self.synthesizedRect);
    self.synthesizedRect = (CGRect){ {1, 2}, {3, 4} };
    JEDump(@"After assignment", self.synthesizedRect);
}


@end
