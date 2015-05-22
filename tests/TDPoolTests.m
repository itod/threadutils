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
    
    id obj1 = @"one";
    self.pool = [TDPool poolWithItems:@[obj1]];
    
    id obj = [pool takeItem];
    TDEqualObjects(@"one", obj);
    
    [pool returnItem:obj];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test2Items1Thread {
    
    id obj1 = @"one";
    id obj2 = @"two";
    self.pool = [TDPool poolWithItems:@[obj1, obj2]];
    
    id took1 = [pool takeItem];
    TDEqualObjects(@"two", took1);
    
    id took2 = [pool takeItem];
    TDEqualObjects(@"one", took2);
    
    [pool returnItem:took1];
    [pool returnItem:took2];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}


- (void)test2Items1ThreadSwap {
    
    id obj1 = @"one";
    id obj2 = @"two";
    self.pool = [TDPool poolWithItems:@[obj1, obj2]];
    
    id took1 = [pool takeItem];
    TDEqualObjects(@"two", took1);
    
    id took2 = [pool takeItem];
    TDEqualObjects(@"one", took2);
    
    [pool returnItem:took2];
    
    id took3 = [pool takeItem];
    TDEqualObjects(@"one", took3);

    [pool returnItem:took1];
    [pool returnItem:took3];
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
    }];
}

- (void)test1Item2Threads {
    
    id obj1 = @"one";
    id obj2 = @"two";
    self.pool = [TDPool poolWithItems:@[obj1, obj2]];
    self.threshold = [TDThreshold thresholdWithValue:1];
    
    TDPerformOnBackgroundThread(^{
        id obj = [pool takeItem];
        TDEqualObjects(@"two", obj);
        [pool returnItem:obj];
        self.counter++;
        [self.threshold await];
        [done fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(1, counter);
        
        id took1 = [pool takeItem];
        TDEqualObjects(@"two", took1);
        id took2 = [pool takeItem];
        TDEqualObjects(@"one", took2);
    }];
}

- (void)test2Items2Threads {
    
    id obj1 = @"one";
    id obj2 = @"two";
    self.pool = [TDPool poolWithItems:@[obj1, obj2]];
    self.threshold = [TDThreshold thresholdWithValue:2];

    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        id obj = [pool takeItem];
        TDEqualObjects(@"one", obj);
        [pool returnItem:obj];
        self.counter++;
        [self.threshold await];
    });
    
    id obj = [pool takeItem];
    TDEqualObjects(@"two", obj);
    self.counter++;
    [self.threshold await];
    [pool returnItem:obj];

    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(2, counter);
        
        id took1 = [pool takeItem];
        TDEqualObjects(@"two", took1);
        id took2 = [pool takeItem];
        TDEqualObjects(@"one", took2);
    }];
}

- (void)test2Items3Threads {
    
    id obj1 = @"one";
    id obj2 = @"two";
    self.pool = [TDPool poolWithItems:@[obj1, obj2]];
    self.threshold = [TDThreshold thresholdWithValue:3];
    
    TDPerformOnBackgroundThreadAfterDelay(0.1, ^{
        id obj = [pool takeItem];
        TDEqualObjects(@"one", obj);
        TDEquals(1, counter);
        self.counter++;
        sleep(2);
        [pool returnItem:obj];
        [self.threshold await];
    });
    
    TDPerformOnBackgroundThreadAfterDelay(0.5, ^{
        TDEquals(2, counter);
        id obj = [pool takeItem];
        TDEqualObjects(@"one", obj);
        self.counter++;
        [self.threshold await];
        [pool returnItem:obj];
    });
    
    id obj = [pool takeItem];
    TDEqualObjects(@"two", obj);
    TDEquals(0, counter);
    self.counter++;
    [self.threshold await];
    [pool returnItem:obj];
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *err) {
        TDNil(err);
        TDEquals(3, counter);
        
        id took1 = [pool takeItem];
        TDEqualObjects(@"two", took1);
        id took2 = [pool takeItem];
        TDEqualObjects(@"one", took2);
    }];
}

@synthesize pool=pool;
@end
