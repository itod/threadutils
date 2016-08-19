//
//  TDExchangerTests.m
//  TDExchangerTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

#define FOO @"foo"
#define BAR @"bar"

@interface TDExchangerTests : TDBaseTestCase
@property (retain) TDExchanger *exchanger;
@end

@implementation TDExchangerTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    self.exchanger = nil;
    [super tearDown];
}

- (void)test1Permit2Threads {
    
    self.exchanger = [TDExchanger exchanger];
    
    TDAtomicOnBackgroundThread(^{
        TDFalse(flag);
        self.flag = YES;
        TDEqualObjects(FOO, [exchanger exchange:BAR]);
    });
    
    TDFalse(flag);
    TDEqualObjects(BAR, [exchanger exchange:FOO]);
    TDTrue(flag);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDTrue(flag);
    }];
}

- (void)test1Permit2ThreadsDelay {
    
    self.exchanger = [TDExchanger exchanger];
    
    TDAtomicOnBackgroundThreadAfterDelay(0.5, ^{
        TDFalse(flag);
        self.flag = YES;
        TDEqualObjects(FOO, [exchanger exchange:BAR]);
    });
    
    TDFalse(flag);
    TDEqualObjects(BAR, [exchanger exchange:FOO]);
    TDTrue(flag);
    
    [done fulfill];
    
    [self waitForExpectationsWithTimeout:0.0 handler:^(NSError *err) {
        TDNil(err);
        TDTrue(flag);
    }];
}

@synthesize exchanger=exchanger;
@end
