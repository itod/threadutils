//
//  TDPipelineStage.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDChannel;

typedef NS_ENUM(NSUInteger, TDPipelineStageType) {
    TDPipelineStageTypeDeterminate = 0,
    TDPipelineStageTypeIndeterminate = 1,
};

@interface TDPipelineStage : NSObject

+ (TDPipelineStage *)pipelineStageWithType:(TDPipelineStageType)type runnableClass:(Class)cls threadCount:(NSUInteger)c;
- (instancetype)initWithType:(TDPipelineStageType)type runnableClass:(Class)cls threadCount:(NSUInteger)c;

@property (nonatomic, assign, readonly) TDPipelineStageType type;
@property (nonatomic, retain, readonly) Class workerClass;
@property (nonatomic, assign, readonly) NSUInteger threadCount;

@property (nonatomic, retain, readonly) id <TDChannel>inputChannel;
@property (nonatomic, retain, readonly) id <TDChannel>outputChannel;

@end

