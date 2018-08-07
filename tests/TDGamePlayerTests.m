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
@property (retain) ThreadSafeCounter *tsc;
@property (assign) BOOL wantsEven;
@end

@implementation Incrementer

- (id)gamePlayer:(TDGamePlayer *)p doTurnWithInput:(id)ignored {
    TDAssert(![NSThread isMainThread]);
    [self.tsc increment];
    
    NSUInteger c = [self.tsc sample];
    
    BOOL isEven = (c % 2 == 0);
    BOOL wantsEven = self.wantsEven;
    
    TDAssert((isEven && wantsEven) || (!isEven && !wantsEven));
    return nil;
}

@end

@interface Incrementer2 : NSObject <TDGamePlayerDelegate>
@property (retain) ThreadSafeCounter *tsc;
@property (assign) BOOL wantsEven;
@end

@implementation Incrementer2

- (id)gamePlayer:(TDGamePlayer *)p doTurnWithInput:(ThreadSafeCounter *)tsc {
    TDAssert(![NSThread isMainThread]);
    TDAssert([tsc isKindOfClass:[ThreadSafeCounter class]]);
    [tsc increment];
    
    NSUInteger c = [tsc sample];
    
    BOOL isEven = (c % 2 == 0);
    BOOL wantsEven = self.wantsEven;
    
    TDAssert((isEven && wantsEven) || (!isEven && !wantsEven));
    return tsc;
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

- (void)testGameWithGlobalCounter {
    ThreadSafeCounter *tsc = [[[ThreadSafeCounter alloc] init] autorelease];
    
    Incrementer *inc1 = [[[Incrementer alloc] init] autorelease];
    inc1.tsc = tsc;
    inc1.wantsEven = NO;

    Incrementer *inc2 = [[[Incrementer alloc] init] autorelease];
    inc2.tsc = tsc;
    inc2.wantsEven = YES;

    self.p1 = [[[TDGamePlayer alloc] initWithDelegate:inc1] autorelease];
    self.p2 = [[[TDGamePlayer alloc] initWithDelegate:inc2] autorelease];
    
    p1.opponent = p2;
    p2.opponent = p1;
    
    [p1 giveFirstTurnWithInput:nil];
    
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
        NSUInteger c = [tsc sample];
        NSLog(@"Turns taken : %@", @(c));
        NSLog(@"");
    }];
}


- (void)testGameWithArgumentCounter {
    ThreadSafeCounter *tsc = [[[ThreadSafeCounter alloc] init] autorelease];
    
    Incrementer2 *inc1 = [[[Incrementer2 alloc] init] autorelease];
    inc1.wantsEven = NO;
    
    Incrementer2 *inc2 = [[[Incrementer2 alloc] init] autorelease];
    inc2.wantsEven = YES;
    
    self.p1 = [[[TDGamePlayer alloc] initWithDelegate:inc1] autorelease];
    self.p2 = [[[TDGamePlayer alloc] initWithDelegate:inc2] autorelease];
    
    p1.opponent = p2;
    p2.opponent = p1;
    
    [p1 giveFirstTurnWithInput:tsc];
    
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
        NSUInteger c = [tsc sample];
        NSLog(@"Turns taken : %@", @(c));
        NSLog(@"");
    }];
}

@synthesize p1=p1;
@synthesize p2=p2;
@end
