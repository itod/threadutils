//
//  TDBaseTestCase.m
//  TDBaseTestCase
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDBaseTestCase.h"

@implementation TDBaseTestCase

- (void)dealloc {
    self.done = nil;
    [super dealloc];
}

- (void)setUp {
    [super setUp];
    self.done = [self expectationWithDescription:@"done"];
    self.flag = NO;
}

- (void)tearDown {
    self.done = nil;
    [super tearDown];
}

- (void)performAtomic:(void(^)(void))block {
    TDNotNil(block);
    @synchronized(self) {
        block();
    }
}

- (void)performAtomic:(NSTimeInterval)delay :(void(^)(void))block {
    TDPerformOnMainThreadAfterDelay(delay, ^{
        TDNotNil(block);
        @synchronized(self) {
            block();
        }
    });
}

- (void)performAtomicInBackground:(void(^)(void))block {
    TDPerformOnBackgroundThread(^{
        TDNotNil(block);
        @synchronized(self) {
            block();
        }
    });
}

- (void)performAtomicInBackground:(NSTimeInterval)delay :(void(^)(void))block {
    TDPerformOnBackgroundThreadAfterDelay(delay, ^{
        TDNotNil(block);
        @synchronized(self) {
            block();
        }
    });
}

@synthesize done=done;
@synthesize flag=flag;
@end
