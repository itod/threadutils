//
//  TDTest.h
//  TDTestUtils
//
//  Created by Todd Ditchendorf on 12/6/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <TDThreadUtils/TDThreadUtils.h>

#define TDTrue(e) XCTAssertTrue((e), @"")
#define TDFalse(e) XCTAssertFalse((e), @"")
#define TDNil(e) XCTAssertNil((e), @"")
#define TDNotNil(e) XCTAssertNotNil((e), @"")
#define TDEquals(e1, e2) XCTAssertEqual((e1), (e2), @"")
#define TDEqualObjects(e1, e2) XCTAssertEqualObjects((e1), (e2), @"")
#define TDFail() XCTFail(@"")

#define TDAssert(expr) NSAssert((expr), @"assertion failure in %s.", __PRETTY_FUNCTION__);
#define TDCAssert(expr) NSCAssert((expr), @"assertion failure in %s.", __PRETTY_FUNCTION__);

#define TDAtomicOnMainThread(block) [self performAtomic:(block)]
#define TDAtomicOnMainThreadAfterDelay(delay, block) [self performAtomic:(delay) :(block)]
#define TDAtomicOnBackgroundThread(block) [self performAtomicInBackground:(block)]
#define TDAtomicOnBackgroundThreadAfterDelay(delay, block) [self performAtomicInBackground:(delay) :(block)]

void TDPerformOnMainThread(void (^block)(void));
void TDPerformOnBackgroundThread(void (^block)(void));
void TDPerformOnMainThreadAfterDelay(double delay, void (^block)(void));
void TDPerformOnBackgroundThreadAfterDelay(double delay, void (^block)(void));
