//
//  TDBoundedBufferTests.m
//  TDBoundedBufferTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

#define ONE @"one"
#define TWO @"two"
#define THREE @"three"
#define FOUR @"four"

@interface TDBoundedBufferTests : TDBaseTestCase
@property (retain) TDBoundedBuffer *buff;
@end

@implementation TDBoundedBufferTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    self.buff = nil;
    [super tearDown];
}

- (void)test1Size1Obj1Thread {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    [buff put:ONE];
    TDEqualObjects(ONE, [buff take]);

    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Size1Obj2Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDPerformOnBackgroundThreadAfterDelay(0.3, ^{
        self.counter++;
        [buff put:ONE];
    });
    
    TDEqualObjects(ONE, [buff take]);
    TDEquals(1, counter);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);
    }];
}

- (void)test1Size2Objs2Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        self.counter++;
        [buff put:ONE];
        self.counter++;
        [buff put:TWO];
    });
    
    TDEqualObjects(ONE, [buff take]);
    TDEqualObjects(TWO, [buff take]);
    TDEquals(2, counter);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, counter);
    }];
}

- (void)test1Size2Objs3Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDPerformOnBackgroundThread(^{
        self.counter++;
        [buff put:ONE];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        self.counter++;
        [buff put:TWO];
    });
    
    TDEqualObjects(ONE, [buff take]);
    TDEqualObjects(TWO, [buff take]);
    TDEquals(2, counter);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDFalse(flag);
        TDEquals(2, counter);
    }];
}

- (void)test1Size2Objs4ThreadsPutOnMain {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    self.threshold = [TDThreshold thresholdWithValue:4];
    
    TDPerformOnBackgroundThread(^{
        id obj = [buff take];
        TDTrue([obj isEqual:ONE] || [obj isEqual:TWO]);
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        [buff put:TWO];
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThread(^{
        id obj = [buff take];
        TDTrue([obj isEqual:ONE] || [obj isEqual:TWO]);
        self.counter++;
        [threshold await];
    });
    
    [buff put:ONE];
    
    [threshold await];
    
    TDEquals(3, counter);
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Size2Objs4ThreadsTakeOnMain {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    self.threshold = [TDThreshold thresholdWithValue:4];
    
    TDPerformOnBackgroundThread(^{
        id obj = [buff take];
        TDTrue([obj isEqual:ONE] || [obj isEqual:TWO]);
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        [buff put:TWO];
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThread(^{
        [buff put:ONE];
        self.counter++;
        [threshold await];
    });
    
    id obj = [buff take];
    TDTrue([obj isEqual:ONE] || [obj isEqual:TWO]);
    
    [threshold await];
    TDEquals(3, counter);
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Size2Objs5Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    self.threshold = [TDThreshold thresholdWithValue:5];
    
    TDPerformOnBackgroundThread(^{
        id obj = [buff take];
        TDTrue([obj isEqual:ONE] || [obj isEqual:TWO]);
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        [buff put:TWO];
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThread(^{
        [buff put:ONE];
        self.counter++;
        [threshold await];
    });
    
    TDPerformOnBackgroundThread(^{
        id obj = [buff take];
        TDTrue([obj isEqual:ONE] || [obj isEqual:TWO]);
        
        self.counter++;
        [threshold await];
    });
    
    [threshold await];
    TDEquals(4, counter);
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

@synthesize buff=buff;
@end
