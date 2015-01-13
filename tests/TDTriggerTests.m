//
//  TDTriggerTests.m
//  TDTriggerTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

@interface TDTriggerTests : TDBaseTestCase
@property (retain) TDTrigger *trig;
@end

@implementation TDTriggerTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    self.trig = nil;
    [super tearDown];
}

- (void)testThread {
    
    self.trig = [TDTrigger trigger];
    
    self.counter++;
    [trig fire];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);
    }];
}

- (void)test2Threads {
    
    self.trig = [TDTrigger trigger];
    
    TDPerformOnBackgroundThread(^{
        self.counter++;
        [trig fire];
    });
    
    [trig await];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);
    }];
}

- (void)test2ThreadsDelay {
    
    self.trig = [TDTrigger trigger];
    
    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
        self.counter++;
        [trig fire];
    });
    
    [trig await];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);
    }];
}

- (void)test3Permits3Threads {
    
    self.trig = [TDTrigger trigger];
    self.threshold = [TDThreshold thresholdWithValue:3];
    
    TDPerformOnBackgroundThread(^{
        [trig await];
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThread(^{
        [trig await];
        self.counter++;
        [threshold await];
    });

    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
        TDEquals(0, counter);
        [trig fire];
        
        [threshold await];
        TDEquals(2, counter);
        
        [done fulfill];
    });

    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, counter);
    }];
}

- (void)test3Permits3ThreadsDelay {
    
    self.trig = [TDTrigger trigger];
    self.threshold = [TDThreshold thresholdWithValue:3];
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        [trig await];
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
        [trig await];
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        TDEquals(0, counter);
        [trig fire];
        
        [threshold await];
        TDEquals(2, counter);
        
        [done fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, counter);
    }];
}

@synthesize trig=trig;
@end
