//
//  TDThreshold.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDSemaphore.h>

@interface TDThreshold : TDSemaphore <TDSync>

+ (instancetype)thresholdWithValue:(NSInteger)value;
@end
