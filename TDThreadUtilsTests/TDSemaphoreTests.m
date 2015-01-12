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
    TDEquals(1, sem.value);
    
    [sem acquire];
    TDEquals(0, sem.value);
    
    TDAtomicInBackground(0.1, ^{
        TDEquals(0, sem.value);
        [sem relinquish];
        TDEquals(1, sem.value);
        [done fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, sem.value);
    }];
}

- (void)test2Permits2Threads {
    
    self.sem = [TDSemaphore semaphoreWithValue:2];
    TDEquals(2, sem.value);
    
    [sem acquire];
    TDEquals(1, sem.value);
    [sem acquire];
    TDEquals(0, sem.value);
    
    TDAtomicInBackground(0.1, ^{
        TDEquals(0, sem.value);
        [sem relinquish];
        TDEquals(1, sem.value);
        [sem relinquish];
        TDEquals(2, sem.value);
        [done fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, sem.value);
    }];
}

- (void)test3Permits2Threads {
    
    self.sem = [TDSemaphore semaphoreWithValue:3];
    TDEquals(3, sem.value);
    
    [sem acquire];
    TDEquals(2, sem.value);
    [sem acquire];
    TDEquals(1, sem.value);
    [sem acquire];
    TDEquals(0, sem.value);
    
    TDAtomicInBackground(0.1, ^{
        TDEquals(0, sem.value);
        [sem relinquish];
        TDEquals(1, sem.value);
        [sem relinquish];
        TDEquals(2, sem.value);
        [sem relinquish];
        TDEquals(3, sem.value);
        [done fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(3, sem.value);
    }];
}

// this is timing dependent. fix.
- (void)test2Permits3Threads {
    
    self.sem = [TDSemaphore semaphoreWithValue:2];
    TDEquals(2, sem.value);
    
    TDAtomicInBackground(0.1, ^{
        [sem acquire];
        TDTrue(sem.value < 2);
    });
    TDAtomicInBackgroundNow(^{
        [sem acquire];
        TDTrue(sem.value < 2);
    });
    
    TDAtomicInBackground(0.1, ^{
        [sem relinquish];
        TDTrue(sem.value > 0 && sem.value <= 2);
    });
    TDAtomicInBackground(0.2, ^{
        [sem relinquish];
        TDTrue(sem.value > 0 && sem.value <= 2);
    });
    
    TDAtomic(0.3, ^{
        [done fulfill];
    });

    [self waitForExpectationsWithTimeout:2.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, sem.value);
    }];
}

@synthesize sem=sem;
@end
