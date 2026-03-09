//
//  TDCounter.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/31/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDCounter : NSObject

+ (instancetype)counterWithValue:(NSInteger)value;
- (instancetype)initWithValue:(NSInteger)value;

- (BOOL)attempt; // returns success immediately
- (BOOL)attemptBeforeDate:(NSDate *)limit; // returns success. can block up to limit

- (void)await; // blocks forever
- (void)increment; // returns immediately
@end
