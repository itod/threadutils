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
    self.queue = [TDLinkedQueue queue];
    
    [queue put:obj1];
    id obj = [queue poll];
    TDEqualObjects(@"one", obj);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test2Items1Thread {

    id obj1 = @"one";
    id obj2 = @"two";
    self.queue = [TDLinkedQueue queue];
    [queue put:obj1];
    [queue put:obj2];
    
    id poll1 = [queue poll];
    TDEqualObjects(@"one", poll1);
    
    id poll2 = [queue poll];
    TDEqualObjects(@"two", poll2);
    
    [done fulfill];

    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Item2ThreadsSwap {

    id obj1 = @"one";
    id obj2 = @"two";
    self.queue = [TDLinkedQueue queue];
    [queue put:obj1];
    [queue put:obj2];
    
    self.threshold = [TDThreshold thresholdWithValue:1];

    TDPerformOnBackgroundThread(^{
        id obj = [queue poll];
        TDEqualObjects(@"one", obj);
        [queue put:obj];
        self.counter++;
        [self.threshold await];
        [done fulfill];
    });

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);

        id took1 = [queue poll];
        TDEqualObjects(@"two", took1);
        id took2 = [queue poll];
        TDEqualObjects(@"one", took2);
    }];
}

- (void)test2Items2Threads {

    id obj1 = @"one";
    id obj2 = @"two";
    self.queue = [TDLinkedQueue queue];
    [queue put:obj1];
    [queue put:obj2];

    self.threshold = [TDThreshold thresholdWithValue:2];

    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        id obj = [queue poll];
        TDEqualObjects(@"two", obj);
        [queue put:obj];
        self.counter++;
        [self.threshold await];
    });

    id obj = [queue poll];
    TDEqualObjects(@"one", obj);
    self.counter++;
    [self.threshold await];
    [queue put:obj];

    [done fulfill];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, counter);

        id took1 = [queue poll];
        TDEqualObjects(@"two", took1);
        id took2 = [queue poll];
        TDEqualObjects(@"one", took2);
    }];
}

//- (void)test2Items3Threads {
//
//    id obj1 = @"one";
//    id obj2 = @"two";
//    self.pool = [TDPool poolWithItems:@[obj1, obj2]];
//    self.threshold = [TDThreshold thresholdWithValue:3];
//
//    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
//        id obj = [pool takeItem];
//        TDEqualObjects(@"one", obj);
//        TDEquals(1, counter);
//        self.counter++;
//        sleep(2);
//        [pool returnItem:obj];
//        [self.threshold await];
//    });
//
//    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
//        TDEquals(2, counter);
//        id obj = [pool takeItem];
//        TDEqualObjects(@"one", obj);
//        self.counter++;
//        [self.threshold await];
//        [pool returnItem:obj];
//    });
//
//    id obj = [pool takeItem];
//    TDEqualObjects(@"two", obj);
//    TDEquals(0, counter);
//    self.counter++;
//    [self.threshold await];
//    [pool returnItem:obj];
//
//    [done fulfill];
//
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
//        TDNil(err);
//        TDEquals(3, counter);
//
//        id took1 = [pool takeItem];
//        TDEqualObjects(@"two", took1);
//        id took2 = [pool takeItem];
//        TDEqualObjects(@"one", took2);
//    }];
//}

@synthesize queue=queue;
@end
