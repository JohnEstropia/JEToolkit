//
//  JEToolkitTests.m
//  JEToolkitTests
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <Foundation/Foundation.h>
#import "JEToolkit.h"


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
    JEDump(100);
    int oneHundred = 100;
    JEDump(oneHundred);
    JEDump(&oneHundred);
    JEDump([NSValue valueWithBytes:&oneHundred objCType:@encode(typeof(oneHundred))]);
    JEDump((50 + 50));
    
    JEDump(12345.12345f);
    JEDump([NSNumber numberWithFloat:12345.12345f]);
    JEDump(12345678901234567890.0f);
    JEDump([NSNumber numberWithFloat:12345678901234567890.0f]);
    JEDump(12345678901234567890.0);
    JEDump([NSNumber numberWithDouble:12345678901234567890.0]);
    JEDump(M_PI);
    JEDump([NSNumber numberWithDouble:M_PI]);
    JEDump(NSIntegerMax);
    JEDump(NSIntegerMin);
    JEDump(CGFLOAT_MAX);
    JEDump([NSNumber numberWithFloat:CGFLOAT_MAX]);
    JEDump(CGFLOAT_MIN);
    JEDump([NSNumber numberWithFloat:CGFLOAT_MIN]);
    JEDump(DBL_MAX);
    JEDump([NSNumber numberWithDouble:DBL_MAX]);
    JEDump(DBL_MIN);
    JEDump([NSNumber numberWithDouble:DBL_MIN]);
    
    JEDump("cstring");
    char *cstringPtr = NULL;
    JEDump(cstringPtr);
    JEDump(&cstringPtr);
    JEDump([NSValue valueWithBytes:&cstringPtr objCType:@encode(typeof(cstringPtr))]);
    cstringPtr = "cstring";
    JEDump(cstringPtr);
    JEDump(&cstringPtr);
    char cstringArray[7] = "cstring";
    JEDumpArray(cstringArray);
    JEDump(&cstringArray);
    JEDump([NSValue valueWithBytes:cstringArray objCType:@encode(typeof(cstringArray))]);
    
    JEDump(_cmd);
    JEDump(@selector(viewDidAppear:));
    SEL selector = NULL;
    JEDump(selector);
    JEDump(&selector);
    JEDump([NSValue valueWithBytes:&selector objCType:@encode(typeof(selector))]);
    selector = _cmd;
    JEDump(selector);
    JEDump(&selector);
    JEDump([NSValue valueWithBytes:&selector objCType:@encode(typeof(selector))]);
    
    
    JEDump([UIView new]);
    UIView * view = nil;
    JEDump(view);
    JEDump(&view);
    JEDump([NSValue valueWithBytes:&view objCType:@encode(typeof(view))]);
    view = [UIView new];
    JEDump(view);
    JEDump(&view);
    JEDump([NSValue valueWithBytes:&view objCType:@encode(typeof(view))]);
    
    NSValue *value = [NSValue valueWithNonretainedObject:view];
    JEDump(value);
    value = [NSValue valueWithPointer:CGColorCreate];
    JEDump(value);
    
    JEDump([view class]);
    JEDump([UIView class]);
    Class class = Nil;
    JEDump(class);
    JEDump(&class);
    JEDump([NSValue valueWithBytes:&class objCType:@encode(typeof(class))]);
    class = [UIView class];
    JEDump(class);
    JEDump(&class);
    JEDump([NSValue valueWithBytes:&class objCType:@encode(typeof(class))]);
    
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:@"testdir" toPath:@"testdir" error:&error];
    JEDump(error);
    
    JEDump(CGRectZero);
    
    JEDump((CGPoint){1.999, 2.999});
    JEDump((CGSize){1.999, 2.999});
    JEDump((CGRect){{1.999, 2.999}, {3.999, 4.999}});
    JEDump((CGAffineTransform){1.999, 2.999, 3.999, 4.999, 5.999, 6.999});
    JEDump((UIEdgeInsets){1.999, 2.999, 3.999, 4.999});
    JEDump((UIOffset){1.999, 2.999});
    JEDump((NSRange){1, 2});
    
    CGRect rect = (CGRect){{1, 2}, {3, 4}};
    JEDump(rect);
    JEDump(&rect);
    JEDump([NSValue valueWithBytes:&rect objCType:@encode(typeof(rect))]);
    
    JEDump(&CGImageCreate);
    
    int intArray[2][3] = {{1, 2, 3}, {4, 5, 6}};
    JEDumpArray(intArray);
    JEDump(&intArray);
    JEDump([NSValue valueWithBytes:intArray objCType:@encode(typeof(intArray))]);
    
    JEDump(^(int intParam, id idParam, CGRect rectParam, NSError ** outErrorParam){ return intParam + 100; });
    int (^block)(int intParam) = NULL;
    JEDump(block);
    JEDump(&block);
    JEDump([NSValue valueWithBytes:&block objCType:@encode(typeof(block))]);
    block = ^(int intParam){ return intParam + 100; };
    JEDump(block);
    JEDump(&block);
    JEDump([NSValue valueWithBytes:&block objCType:@encode(typeof(block))]);
    dispatch_block_t voidBlock = ^{ };
    JEDump(voidBlock);
    
    JEDump(FLT_DIG);
    JEDump(DBL_DIG);
    JEDump(LDBL_DIG);
    JEDump(DECIMAL_DIG);
    
    long double longDouble = 11111.9999888888888888;
    JEDump(longDouble);
    
    JEDump(0.12345f);
    JEDump(0.123456f);
    JEDump(0.1234567f);
    JEDump(0.12345678f);
    JEDump(0.123456789f);
    JEDump(0.1234567899f);
    JEDump(0.12345678991f);
    JEDump(0.123456789912f);
    JEDump(123.123f);
    JEDump(1234.1234f);
    JEDump(12345.12345f);
    JEDump(123456.123456f);
    JEDump(1234567.1234567f);
    JEDump(12345678.12345678f);
    JEDump(123456789.123456789f);
    JEDump(1234567899.1234567899f);
    
    JEDump(0.1234567);
    JEDump(0.12345678);
    JEDump(0.123456789);
    JEDump(0.1234567899);
    JEDump(0.12345678991);
    JEDump(0.123456789912);
    JEDump(0.1234567899123);
    JEDump(0.12345678991234);
    JEDump(0.123456789912345);
    JEDump(0.1234567899123456);
    JEDump(0.12345678991234567);
    JEDump(0.123456789912345678);
    JEDump(0.1234567899123456789);
    JEDump(0.12345678991234567899);
    JEDump(0.123456789912345678991);
    JEDump(123456.123456);
    JEDump(1234567.1234567);
    JEDump(12345678.12345678);
    JEDump(123456789.123456789);
    JEDump(1234567899.1234567899);
    JEDump(12345678991.12345678991);
    JEDump(123456789912.123456789912);
    JEDump(1234567899123.1234567899123);
    JEDump(12345678991234.12345678991234);
    JEDump(123456789912345.123456789912345);
    JEDump(1234567899123456.1234567899123456);
    JEDump(12345678991234567.12345678991234567);
    JEDump(123456789912345678.123456789912345678);
    JEDump(1234567899123456789.1234567899123456789);
    JEDump(12345678991234567899.0);
    
    JEDump(0.123456789912l);
    JEDump(0.1234567899123l);
    JEDump(0.12345678991234l);
    JEDump(0.123456789912345l);
    JEDump(0.1234567899123456l);
    JEDump(0.12345678991234567l);
    JEDump(0.123456789912345678l);
    JEDump(0.1234567899123456789l);
    JEDump(0.12345678991234567899l);
    JEDump(0.123456789912345678991l);
    JEDump(0.1234567899123456789912l);
    JEDump(0.12345678991234567899123l);
    JEDump(0.123456789912345678991234l);
    JEDump(123456.123456l);
    JEDump(1234567.1234567l);
    JEDump(12345678.12345678l);
    JEDump(123456789.123456789l);
    JEDump(1234567899.1234567899l);
    JEDump(12345678991.12345678991l);
    JEDump(123456789912.123456789912l);
    JEDump(1234567899123.1234567899123l);
    JEDump(12345678991234.12345678991234l);
    JEDump(123456789912345.123456789912345l);
    JEDump(1234567899123456.1234567899123456l);
    JEDump(12345678991234567.1234567l);
    JEDump(123456789912345678.12345678l);
    JEDump(1234567899123456789.123456789l);
    JEDump(12345678991234567899.1234567899l);
    JEDump(123456789912345678991.12345678991l);
    JEDump(1234567899123456789912.123456789912l);
    JEDump(12345678991234567899123.1234567899123l);
    
    
    JELog(@"No Parameters");
    JELog(@"Many Parameters: %@, %d, %f", @"yo", 10, 20.4f);
}

JESynthesizeObject(id, synthesizedId, setSynthesizedId, JESynthesizeRetainNonatomic);
JESynthesizeObject(void(^)(void), synthesizedBlock, setSynthesizedBlock, JESynthesizeCopyNonatomic);
JESynthesizeObject(id, synthesizedAssign, setSynthesizedAssign, JESynthesizeAssign);
JESynthesizeScalar(CGRect, synthesizedRect, setSynthesizedRect);

- (void)testSynthesized
{
    JEDump(self.synthesizedId);
    self.synthesizedId = @"test";
    JEDump(self.synthesizedId);
    
    JEDump(self.synthesizedBlock);
    self.synthesizedBlock = ^{ };
    JEDump(self.synthesizedBlock);
    
    JEDump(self.synthesizedAssign);
    self.synthesizedAssign = self;
    JEDump(self.synthesizedAssign);
    
    JEDump(self.synthesizedRect);
    self.synthesizedRect = (CGRect){ {1, 2}, {3, 4} };
    JEDump(self.synthesizedRect);
}


@end
