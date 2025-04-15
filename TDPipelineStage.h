//
//  TDPipelineStage.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDChannel;

@interface TDPipelineStage : NSObject

+ (TDPipelineStage *)pipelineStageWithRunnableClass:(Class)cls threadCount:(NSUInteger)c;
- (instancetype)initWithRunnableClass:(Class)cls threadCount:(NSUInteger)c;

@property (nonatomic, retain, readonly) Class workerClass;
@property (nonatomic, assign, readonly) NSUInteger threadCount;

@property (nonatomic, retain, readonly) id <TDChannel>inputChannel;
@property (nonatomic, retain, readonly) id <TDChannel>outputChannel;

@end

