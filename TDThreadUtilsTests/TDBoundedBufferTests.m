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
    
    TDAtomicInBackground(0.5, ^{
        [buff put:ONE];
        self.flag = YES;
    });
    
    TDEqualObjects(ONE, [buff take]);
    TDTrue(flag);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Size2Objs2Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDAtomicInBackground(0.5, ^{
        self.flag = YES;
        [buff put:ONE];
        [buff put:TWO];
    });
    
    TDFalse(flag);
    TDEqualObjects(ONE, [buff take]);
    TDTrue(flag);
    TDEqualObjects(TWO, [buff take]);
    self.flag = NO;
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDFalse(flag);
    }];
}

- (void)test1Size2Objs3Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDAtomicInBackgroundNow(^{
        self.flag = YES;
        [buff put:ONE];
    });
    
    TDAtomicInBackground(0.5, ^{
        self.flag = NO;
        [buff put:TWO];
    });
    
    TDEqualObjects(ONE, [buff take]);
    TDTrue(flag);
    TDEqualObjects(TWO, [buff take]);
    TDFalse(flag);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDFalse(flag);
    }];
}

- (void)test1Size2Objs4Threads {
    
    self.buff = [TDBoundedBuffer boundedBufferWithSize:1];
    
    TDAtomicInBackgroundNow(^{
        self.flag = YES;
        [buff put:ONE];
    });
    
    TDAtomicInBackgroundNow(^{
        self.flag = NO;
        [buff put:TWO];
        TDEqualObjects(TWO, [buff take]);
    });
    
    TDEqualObjects(ONE, [buff take]);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

@synthesize buff=buff;
@end
