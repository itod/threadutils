//
//  TDThreshold.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDThreshold : NSObject

+ (instancetype)thresholdWithValue:(NSInteger)value;
- (instancetype)initWithValue:(NSInteger)value;

- (void)await;
@end
