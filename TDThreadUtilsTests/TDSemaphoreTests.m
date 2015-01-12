//
//  TDSemaphoreTests.m
//  TDSemaphoreTests
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

@interface TDSemaphore ()
@property (assign) NSInteger value;
@end

@interface TDSemaphoreTests : XCTestCase
@property (nonatomic, retain) TDSemaphore *sem;
@end

@implementation TDSemaphoreTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    self.sem = nil;
    [super tearDown];
}

- (void)test1Permit {
    self.sem = [TDSemaphore semaphoreWithValue:1];
    
    [sem acquire];
    TDEquals(0, sem.value);
}

@synthesize sem=sem;
@end
