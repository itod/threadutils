//
//  TDThresholdTests.m
//  TDThresholdTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

@interface TDThresholdTests : TDBaseTestCase
@property (retain) TDThreshold *th;
@end

@implementation TDThresholdTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    self.th = nil;
    [super tearDown];
}

- (void)test1Permit1Thread {
    
    self.th = [TDThreshold thresholdWithValue:1];
    
    self.counter++;
    [th await];
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);
    }];
}

- (void)test1Permit2Threads {
    
    self.th = [TDThreshold thresholdWithValue:1];
    
    TDPerformOnBackgroundThread(^{
        self.counter++;
        [th await];
        [done fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);
    }];
}

- (void)test2Permits2Threads {
    
    self.th = [TDThreshold thresholdWithValue:2];
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        self.counter++;
        [th await];
    });
    
    self.counter++;
    [th await];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, counter);
    }];
}

- (void)test3Permits3Threads {
    
    self.th = [TDThreshold thresholdWithValue:3];
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        self.counter++;
        [th await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
        self.counter++;
        [th await];
    });
    
    self.counter++;
    [th await];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(3, counter);
    }];
}

- (void)test4Permits4Threads {
    
    self.th = [TDThreshold thresholdWithValue:4];
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        self.counter++;
        [th await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
        self.counter++;
        [th await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.3, ^{
        self.counter++;
        [th await];
    });
    
    self.counter++;
    [th await];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(4, counter);
    }];
}

@synthesize th=th;
@end
