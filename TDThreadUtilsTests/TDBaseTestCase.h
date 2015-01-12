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
    BOOL flag;
}

- (void)performAtomic:(void(^)(void))block;
- (void)performAtomic:(NSTimeInterval)delay :(void(^)(void))block;
- (void)performAtomicInBackground:(void(^)(void))block;
- (void)performAtomicInBackground:(NSTimeInterval)delay :(void(^)(void))block;

@property (retain) XCTestExpectation *done;
@property (assign) BOOL flag;
@end
