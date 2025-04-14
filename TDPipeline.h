//
//  TDPipeline.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPipeline : NSObject

+ (TDPipeline *)pipleineWithStages:(NSArray *)stages;
- (instancetype)initWithStages:(NSArray *)stages;

@property (nonatomic, copy, readonly) NSArray *stages;

- (BOOL)runWithError:(NSError **)outErr;

@end
