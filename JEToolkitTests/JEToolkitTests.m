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
    je_dump(100);
    int oneHundred = 100;
    je_dump(oneHundred);
    je_dump(&oneHundred);
    je_dump((50 + 50));
    
    je_dump("cstring");
    char *cstringPtr = NULL;
    je_dump(cstringPtr);
    je_dump(&cstringPtr);
    cstringPtr = "cstring";
    je_dump(cstringPtr);
    je_dump(&cstringPtr);
    char cstringArray[7] = "cstring";
    je_dumpArray(cstringArray);
    je_dump(&cstringArray);
    
    
    je_dump(_cmd);
    je_dump(@selector(viewDidAppear:));
    SEL selector = NULL;
    je_dump(selector);
    je_dump(&selector);
    selector = _cmd;
    je_dump(selector);
    je_dump(&selector);
    
    je_dump([UIView new]);
    UIView *view = nil;
    je_dump(view);
    je_dump(&view);
    view = [UIView new];
    je_dump(view);
    je_dump(&view);
    
    je_dump([view class]);
    je_dump([UIView class]);
    Class class = Nil;
    je_dump(class);
    je_dump(&class);
    class = [UIView class];
    je_dump(class);
    je_dump(&class);
    
    je_dump(CGRectZero);
    je_dump((CGRect){{1, 2}, {3, 4}});
    CGRect rect = (CGRect){{1, 2}, {3, 4}};
    je_dump(rect);
    je_dump(&rect);
    
    je_dump(&CGImageCreate);
    
    int intArray[2][3] = {{1, 2, 3}, {4, 5, 6}};
    je_dumpArray(intArray);
    je_dump(&intArray);
    
    je_dump(^(int intParam, id idParam, CGRect rectParam, NSError ** outErrorParam){ return intParam + 100; });
    int (^block)(int intParam) = NULL;
    je_dump(block);
    je_dump(&block);
    block = ^(int intParam){ return intParam + 100; };
    je_dump(block);
    je_dump(&block);
    dispatch_block_t voidBlock = ^{ };
    je_dump(voidBlock);
}

@end
