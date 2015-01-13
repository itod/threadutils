//
//  TDBaseTestCase.m
//  TDBaseTestCase
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

@interface TDBaseTestCase : XCTestCase {
    XCTestExpectation *done;
    TDThreshold *threshold;
    BOOL flag;
    NSInteger counter;
}

- (void)performAtomic:(void(^)(void))block;
- (void)performAtomic:(NSTimeInterval)delay :(void(^)(void))block;
- (void)performAtomicInBackground:(void(^)(void))block;
- (void)performAtomicInBackground:(NSTimeInterval)delay :(void(^)(void))block;

@property (retain) XCTestExpectation *done;
@property (retain) TDThreshold *threshold;
@property (assign) BOOL flag;
@property (assign) NSInteger counter;
@end
