//
//  TDPoolTests.m
//  TDPoolTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

@interface TDPoolTests : TDBaseTestCase
@property (retain) TDPool *pool;
@end

@implementation TDPoolTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    self.pool = nil;
    [super tearDown];
}

- (void)test1Item1Thread {
    
    self.pool = [TDPool poolWithSize:1 initializationBlock:^NSArray *(NSUInteger size) {
        id obj1 = @"one";
        return @[obj1];
    }];

    id obj = [pool takeItem];
    TDEqualObjects(@"one", obj);
    
    [pool returnItem:obj];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

//- (void)test1Permit2Threads {
//    
//    self.th = [TDThreshold thresholdWithValue:1];
//    
//    TDPerformOnBackgroundThread(^{
//        self.counter++;
//        [th await];
//        [done fulfill];
//    });
//    
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
//        TDNil(err);
//        TDEquals(1, counter);
//    }];
//}
//
//- (void)test2Permits2Threads {
//    
//    self.th = [TDThreshold thresholdWithValue:2];
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
//        self.counter++;
//        [th await];
//    });
//    
//    self.counter++;
//    [th await];
//    [done fulfill];
//    
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
//        TDNil(err);
//        TDEquals(2, counter);
//    }];
//}
//
//- (void)test3Permits3Threads {
//    
//    self.th = [TDThreshold thresholdWithValue:3];
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
//        self.counter++;
//        [th await];
//    });
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
//        self.counter++;
//        [th await];
//    });
//    
//    self.counter++;
//    [th await];
//    [done fulfill];
//    
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
//        TDNil(err);
//        TDEquals(3, counter);
//    }];
//}
//
//- (void)test4Permits4Threads {
//    
//    self.th = [TDThreshold thresholdWithValue:4];
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
//        self.counter++;
//        [th await];
//    });
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
//        self.counter++;
//        [th await];
//    });
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.3, ^{
//        self.counter++;
//        [th await];
//    });
//    
//    self.counter++;
//    [th await];
//    [done fulfill];
//    
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
//        TDNil(err);
//        TDEquals(4, counter);
//    }];
//}

@synthesize pool=pool;
@end
