//
//  JEToolkitTests.m
//  JEToolkitTests
//
//  Created by John Rommel Estropia on 2013/08/10.
//  Copyright (c) 2013 John Rommel Estropia. All rights reserved.
//

#import <XCTest/XCTest.h>

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
    JEDump([NSDecimalNumber numberWithFloat:12345.12345f]);
    JEDump(12345678901234567890.0f);
    JEDump([NSDecimalNumber numberWithFloat:12345678901234567890.0f]);
    JEDump(12345678901234567890.0);
    JEDump([NSDecimalNumber numberWithDouble:12345678901234567890.0]);
    JEDump(M_PI);
    JEDump([NSDecimalNumber numberWithDouble:M_PI]);
    JEDump(NSIntegerMax);
    JEDump(NSIntegerMin);
    JEDump(CGFLOAT_MAX);
    JEDump([NSDecimalNumber numberWithFloat:CGFLOAT_MAX]);
    JEDump(CGFLOAT_MIN);
    JEDump([NSDecimalNumber numberWithFloat:CGFLOAT_MIN]);
    JEDump(DBL_MAX);
    JEDump([NSDecimalNumber numberWithDouble:DBL_MAX]);
    JEDump(DBL_MIN);
    JEDump([NSDecimalNumber numberWithDouble:DBL_MIN]);
    
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
    JEDump((CGRect){{1, 2}, {3, 4}});
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
