//
//  TDBoundedBufferTests.m
//  TDBoundedBufferTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

#define ONE @"one"
#define TWO @"two"
#define THREE @"three"
#define FOUR @"four"

@interface TDBoundedBufferTests : XCTestCase
@property (retain) TDBoundedBuffer *buff;
@property (retain) XCTestExpectation *done;
@property (assign) BOOL flag;
@end

@implementation TDBoundedBufferTests

- (void)setUp {
    [super setUp];
    self.flag = NO;
    self.done = [self expectationWithDescription:@"done"];
}

- (void)tearDown {
    self.buff = nil;
    self.done = nil;
    [super tearDown];
}

- (void)test1Size1Obj1Thread {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    [buff put:ONE];
    TDEqualObjects(ONE, [buff take]);

    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Size1Obj2Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        [buff put:ONE];
    });
    
    TDEqualObjects(ONE, [buff take]);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Size2Objs2Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        self.flag = YES;
        [buff put:ONE];
        [buff put:TWO];
    });
    
    TDFalse(flag);
    TDEqualObjects(ONE, [buff take]);
    TDTrue(flag);
    TDEqualObjects(TWO, [buff take]);
    self.flag = NO;
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDFalse(flag);
    }];
}

@synthesize buff=buff;
@synthesize done=done;
@synthesize flag=flag;
@end
