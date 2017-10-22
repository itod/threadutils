//
//  TDLinkedQueueTests.m
//  TDLinkedQueueTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

@interface TDLinkedQueueTests : TDBaseTestCase
@property (retain) TDLinkedQueue *queue;
@end

@implementation TDLinkedQueueTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    self.queue = nil;
    [super tearDown];
}

- (void)test1Item1Thread {
    
    id obj1 = @"one";
    self.queue = [[[TDLinkedQueue alloc] init] autorelease];
    
    [queue put:obj1];
    id obj = [queue take];
    TDEqualObjects(@"one", obj);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test2Items1Thread {

    id obj1 = @"one";
    id obj2 = @"two";
    self.queue = [[[TDLinkedQueue alloc] init] autorelease];
    [queue put:obj1];
    [queue put:obj2];
    
    id poll1 = [queue take];
    TDEqualObjects(@"one", poll1);
    
    id poll2 = [queue take];
    TDEqualObjects(@"two", poll2);
    
    [done fulfill];

    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Item2ThreadsSwap {

    id obj1 = @"one";
    id obj2 = @"two";
    self.queue = [[[TDLinkedQueue alloc] init] autorelease];
    [queue put:obj1];
    [queue put:obj2];
    
    self.threshold = [TDThreshold thresholdWithValue:1];

    TDPerformOnBackgroundThread(^{
        id obj = [queue take];
        TDEqualObjects(@"one", obj);
        [queue put:obj];
        self.counter++;
        [self.threshold await];
        [done fulfill];
    });

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);

        id took1 = [queue take];
        TDEqualObjects(@"two", took1);
        id took2 = [queue take];
        TDEqualObjects(@"one", took2);
    }];
}

- (void)test2Items2Threads {

    id obj1 = @"one";
    id obj2 = @"two";
    self.queue = [[[TDLinkedQueue alloc] init] autorelease];
    [queue put:obj1];
    [queue put:obj2];

    self.threshold = [TDThreshold thresholdWithValue:2];

    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        id obj = [queue take];
        TDEqualObjects(@"two", obj);
        [queue put:obj];
        self.counter++;
        [self.threshold await];
    });

    id obj = [queue take];
    TDEqualObjects(@"one", obj);
    self.counter++;
    [self.threshold await];
    [queue put:obj];

    [done fulfill];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, counter);

        id took1 = [queue take];
        TDEqualObjects(@"two", took1);
        id took2 = [queue take];
        TDEqualObjects(@"one", took2);
    }];
}

@synthesize queue=queue;
@end
