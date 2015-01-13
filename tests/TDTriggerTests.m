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

//- (void)test2Threads {
//    
//    self.trig = [TDTrigger trigger];
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
//        self.counter++;
//        [trig await];
//    });
//    
//    self.counter++;
//    [trig await];
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
//    self.trig = [TDTrigger trigger];
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
//        self.counter++;
//        [trig await];
//    });
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
//        self.counter++;
//        [trig await];
//    });
//    
//    self.counter++;
//    [trig await];
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
//    self.trig = [TDTrigger trigger];
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
//        self.counter++;
//        [trig await];
//    });
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.2, ^{
//        self.counter++;
//        [trig await];
//    });
//    
//    TDPerformOnBackgroundThreadAfterDelay(0.3, ^{
//        self.counter++;
//        [trig await];
//    });
//    
//    self.counter++;
//    [trig await];
//    [done fulfill];
//    
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
//        TDNil(err);
//        TDEquals(4, counter);
//    }];
//}

@synthesize trig=trig;
@end
