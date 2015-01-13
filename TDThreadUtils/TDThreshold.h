//
//  TDThreshold.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDSync.h>

@interface TDThreshold : NSObject <TDSync>

+ (instancetype)thresholdWithValue:(NSInteger)value;
- (instancetype)initWithValue:(NSInteger)value;

- (void)acquire;
- (void)relinquish;
@end
