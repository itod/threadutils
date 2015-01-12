//
//  TDSynchronousChannelTests.m
//  TDSynchronousChannelTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

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
        TDFalse(self.flag);
        self.flag = YES;
        TDEqualObjects(@"foobar", chan.item);
        TDEqualObjects(@"foobar", [chan take]);
        TDNil(chan.item);
    });
    
    TDFalse(self.flag);
    [chan put:@"foobar"];
    TDTrue(self.flag);
    TDEqualObjects(nil, chan.item);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDNil(chan.item);
        TDTrue(self.flag);
    }];
}

- (void)test1Permit2ThreadsDelay {
    
    self.chan = [TDSynchronousChannel synchronousChannel];
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        TDFalse(self.flag);
        self.flag = YES;
        TDEqualObjects(@"foobar", chan.item);
        TDEqualObjects(@"foobar", [chan take]);
        TDNil(chan.item);
    });
    
    TDFalse(self.flag);
    [chan put:@"foobar"];
    TDTrue(self.flag);
    TDEqualObjects(nil, chan.item);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDNil(chan.item);
        TDTrue(self.flag);
    }];
}

@synthesize chan=chan;
@synthesize done=done;
@end
