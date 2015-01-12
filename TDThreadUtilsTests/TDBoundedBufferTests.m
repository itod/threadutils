//
//  TDBoundedBufferTests.m
//  TDBoundedBufferTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

#define FOOBAR @"foobar"

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

- (void)test1With1Thread {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    [buff put:FOOBAR];
    TDEqualObjects(FOOBAR, [buff take]);

    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1With2Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        [buff put:FOOBAR];
    });
    
    TDEqualObjects(FOOBAR, [buff take]);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

@synthesize buff=buff;
@synthesize done=done;
@synthesize flag=flag;
@end
