//
//  TDTest.m
//  TDTestUtils
//
//  Created by Todd Ditchendorf on 12/6/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import "TDTest.h"

void TDPerformOnMainThread(void (^block)(void)) {
    TDCAssert(block);
    dispatch_async(dispatch_get_main_queue(), block);
}


void TDPerformOnBackgroundThread(void (^block)(void)) {
    TDCAssert(block);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


void TDPerformOnMainThreadAfterDelay(double delay, void (^block)(void)) {
    TDCAssert(block);
    TDCAssert(delay >= 0.0);
    
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}


void TDPerformOnBackgroundThreadAfterDelay(double delay, void (^block)(void)) {
    TDCAssert(block);
    TDCAssert(delay >= 0.0);
    
    double delayInSeconds = delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}
