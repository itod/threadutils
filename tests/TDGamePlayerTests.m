//
//  TDPoolTests.m
//  TDPoolTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

@interface ThreadSafeCounter : NSObject {
    NSUInteger _c;
}
- (void)increment;
- (NSUInteger)sample;
@end

@implementation ThreadSafeCounter

- (void)increment {
    @synchronized(self) {
        _c++;
    }
}


- (NSUInteger)sample {
    NSUInteger c = 0;
    @synchronized(self) {
        c = _c;
    }
    return c;
}

@end

@interface Incrementer : NSObject <TDGamePlayerDelegate>
@property (retain) ThreadSafeCounter *counter;
@property (assign) BOOL wantsEven;
@end

@implementation Incrementer

- (void)executeMoveForGamePlayer:(TDGamePlayer *)p {
    TDAssert(![NSThread isMainThread]);
    [self.counter increment];
    
    NSUInteger c = [self.counter sample];
    
    BOOL isEven = (c % 2 == 0);
    BOOL wantsEven = self.wantsEven;
    
    TDAssert((isEven && wantsEven) || (!isEven && !wantsEven));
}

@end

@interface TDGamePlayerTests : TDBaseTestCase
@property (retain) TDGamePlayer *p1;
@property (retain) TDGamePlayer *p2;
@end

@implementation TDGamePlayerTests

- (void)setUp {
    [super setUp];
    // here
}

- (void)tearDown {
    [p1 stop];
    [p2 stop];
    
    self.p1 = nil;
    self.p2 = nil;
    [super tearDown];
}

- (void)testGameWithCounter {
    ThreadSafeCounter *counter = [[[ThreadSafeCounter alloc] init] autorelease];
    
    Incrementer *inc1 = [[[Incrementer alloc] init] autorelease];
    inc1.counter = counter;
    inc1.wantsEven = NO;

    Incrementer *inc2 = [[[Incrementer alloc] init] autorelease];
    inc2.counter = counter;
    inc2.wantsEven = YES;

    self.p1 = [[[TDGamePlayer alloc] initWithDelegate:inc1] autorelease];
    self.p2 = [[[TDGamePlayer alloc] initWithDelegate:inc2] autorelease];
    
    p1.opponent = p2;
    p2.opponent = p1;
    
    [p1 takeTurn];
    
    TDPerformOnBackgroundThread(^{
        [p1 run];
    });
    TDPerformOnBackgroundThread(^{
        [p2 run];
    });

    TDPerformOnMainThreadAfterDelay(2.0, ^{
        [p1 stop];
        [p2 stop];
        
        TDPerformOnMainThreadAfterDelay(0.0, ^{
            [done fulfill];
        });
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *err) {
        NSUInteger c = [counter sample];
        NSLog(@"Turns taken : %@", @(c));
        NSLog(@"");
    }];
}

@synthesize p1=p1;
@synthesize p2=p2;
@end
