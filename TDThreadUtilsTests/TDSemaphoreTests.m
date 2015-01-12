//
//  TDSemaphoreTests.m
//  TDSemaphoreTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

@interface TDSemaphore ()
@property (assign) NSInteger value;
@end

@interface TDSemaphoreTests : XCTestCase
@property (nonatomic, retain) TDSemaphore *sem;
@property (nonatomic, retain) XCTestExpectation *done;
@end

@implementation TDSemaphoreTests

- (void)setUp {
    [super setUp];
    self.done = [self expectationWithDescription:@"done"];
}

- (void)tearDown {
    self.sem = nil;
    self.done = nil;
    [super tearDown];
}

- (void)test1Permit {
    
    self.sem = [TDSemaphore semaphoreWithValue:1];
    
    [sem acquire];
    TDEquals(0, sem.value);
    
    TDPerformOnMainThreadAfterDelay(0.1, ^{
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

@synthesize sem=sem;
@synthesize done=done;
@end
