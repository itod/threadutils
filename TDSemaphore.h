//
//  TDSemaphore.h
//  Panthro
//
//  Created by Todd Ditchendorf on 5/31/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import "TDSync.h"

@interface TDSemaphore : NSObject <TDSync>

+ (instancetype)semaphoreWithValue:(NSInteger)value;
- (instancetype)initWithValue:(NSInteger)value;

- (BOOL)attempt; // returns success immediately
- (BOOL)attemptBeforeDate:(NSDate *)limit; // returns success. can block up to limit

- (void)acquire; // blocks forever
- (void)relinquish; // returns immediately
@end
