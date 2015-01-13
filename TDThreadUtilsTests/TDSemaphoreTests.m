//
//  TDSemaphoreTests.m
//  TDSemaphoreTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

@interface TDSemaphore ()
@property (assign) NSInteger value;
@end

@interface TDSemaphoreTests : TDBaseTestCase
@property (retain) TDSemaphore *sem;
@end

@implementation TDSemaphoreTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    self.sem = nil;
    [super tearDown];
}

- (void)test1Permit2Threads {
    
    self.sem = [TDSemaphore semaphoreWithValue:1];
    self.threshold = [TDThreshold thresholdWithValue:2];
    TDEquals(1, sem.value);
    
    [sem acquire];
    TDEquals(0, sem.value);
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        TDEquals(0, sem.value);
        [sem relinquish];
        TDEquals(1, sem.value);
        
        [threshold await];
    });
    
    [threshold await];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, sem.value);
    }];
}

- (void)test2Permits2Threads {
    
    self.sem = [TDSemaphore semaphoreWithValue:2];
    self.threshold = [TDThreshold thresholdWithValue:2];
    TDEquals(2, sem.value);
    
    [sem acquire];
    TDEquals(1, sem.value);
    [sem acquire];
    TDEquals(0, sem.value);
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        TDEquals(0, sem.value);
        [sem relinquish];
        TDEquals(1, sem.value);
        
        [sem relinquish];
        TDEquals(2, sem.value);

        [threshold await];
    });
    
    [threshold await];
    [done fulfill];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, sem.value);
    }];
}

- (void)test3Permits2Threads {
    
    self.sem = [TDSemaphore semaphoreWithValue:3];
    self.threshold = [TDThreshold thresholdWithValue:2];
    TDEquals(3, sem.value);
    
    [sem acquire];
    TDEquals(2, sem.value);
    [sem acquire];
    TDEquals(1, sem.value);
    [sem acquire];
    TDEquals(0, sem.value);
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        TDEquals(0, sem.value);
        [sem relinquish];
        TDEquals(1, sem.value);
        [sem relinquish];
        TDEquals(2, sem.value);
        [sem relinquish];
        TDEquals(3, sem.value);
        
        [threshold await];
    });

    [threshold await];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(3, sem.value);
    }];
}

- (void)test2Permits5Threads {
    
    self.sem = [TDSemaphore semaphoreWithValue:2];
    self.threshold = [TDThreshold thresholdWithValue:5];
    TDEquals(2, sem.value);
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        [sem acquire];
        TDTrue(sem.value < 2);
        [threshold await];
    });
    TDPerformOnBackgroundThread(^{
        [sem acquire];
        TDTrue(sem.value < 2);
        [threshold await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        [sem relinquish];
        TDTrue(sem.value > 0 && sem.value <= 2);
        [threshold await];
    });
    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
        [sem relinquish];
        TDTrue(sem.value > 0 && sem.value <= 2);
        [threshold await];
    });
    
    [threshold await];
    [done fulfill];

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, sem.value);
    }];
}

@synthesize sem=sem;
@end
