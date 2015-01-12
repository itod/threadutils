//
//  TDSynchronousChannelTests.m
//  TDSynchronousChannelTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

#define FOOBAR @"foobar"

@interface TDSynchronousChannel ()
@property (retain) id item;
@end

@interface TDSynchronousChannelTests : XCTestCase
@property (retain) TDSynchronousChannel *chan;
@property (retain) XCTestExpectation *done;
@property (assign) BOOL flag;
@end

@implementation TDSynchronousChannelTests

- (void)setUp {
    [super setUp];
    self.flag = NO;
    self.done = [self expectationWithDescription:@"done"];
}

- (void)tearDown {
    self.chan = nil;
    self.done = nil;
    [super tearDown];
}

- (void)test1Permit2Threads {
    
    self.chan = [TDSynchronousChannel synchronousChannel];
    
    TDPerformOnBackgroundThread(^{
        TDFalse(flag);
        self.flag = YES;
        TDEqualObjects(FOOBAR, chan.item);
        TDEqualObjects(FOOBAR, [chan take]);
        TDNil(chan.item);
    });
    
    TDFalse(flag);
    [chan put:FOOBAR];
    TDTrue(flag);
    TDEqualObjects(nil, chan.item);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDNil(chan.item);
        TDTrue(flag);
    }];
}

- (void)test1Permit2ThreadsDelay {
    
    self.chan = [TDSynchronousChannel synchronousChannel];
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        TDFalse(flag);
        self.flag = YES;
        TDEqualObjects(FOOBAR, chan.item);
        TDEqualObjects(FOOBAR, [chan take]);
        TDNil(chan.item);
    });
    
    TDFalse(flag);
    [chan put:FOOBAR];
    TDTrue(flag);
    TDEqualObjects(nil, chan.item);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDNil(chan.item);
        TDTrue(flag);
    }];
}

@synthesize chan=chan;
@synthesize done=done;
@synthesize flag=flag;
@end
