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
@end

@implementation TDSynchronousChannelTests

- (void)setUp {
    [super setUp];
    self.done = [self expectationWithDescription:@"done"];
}

- (void)tearDown {
    self.chan = nil;
    self.done = nil;
    [super tearDown];
}

- (void)test1Permit2Threads {
    
    self.chan = [TDSynchronousChannel synchronousChannel];
    
    [chan put:@"foobar"];
    TDEqualObjects(@"foobar", chan.item);

    [done fulfill];

    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *err) {
        TDNil(err);
        TDNil(chan.item);
    }];

    TDPerformOnMainThreadAfterDelay(0.0, ^{
        TDEqualObjects(@"foobar", chan.item);
        TDEqualObjects(@"foobar", [chan take]);
        TDNil(chan.item);
    });
}

@synthesize chan=chan;
@synthesize done=done;
@end
