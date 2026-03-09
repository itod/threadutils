//
//  TDPipelineStage.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TDPipelineStageType) {
    TDPipelineStageTypeDeterminate = 0,
    TDPipelineStageTypeIndeterminate = 1,
};

@protocol TDChannel;
@class TDPipelineStage;
@class TDRunner;
@class TDCounter;

@protocol TDPipelineStageDelegate <NSObject>
- (void)pipelineStageProgressDidUpdate:(TDPipelineStage *)ps;
@end

@interface TDPipelineStage : NSObject

+ (TDPipelineStage *)bottleneckStage;
+ (TDPipelineStage *)pipelineStageWithWorkerClass:(Class)cls workerCount:(NSUInteger)c;
- (instancetype)initWithWorkerClass:(Class)cls workerCount:(NSUInteger)c;

@property (nonatomic, retain, readonly) Class workerClass;
@property (nonatomic, assign, readonly) NSUInteger workerCount;

@property (nonatomic, copy, readonly) NSArray<TDRunner *> *runners;

@property (nonatomic, retain, readonly) id <TDChannel>inputChannel;
@property (nonatomic, retain, readonly) id <TDChannel>outputChannel;

@property (nonatomic, assign) id <TDPipelineStageDelegate>delegate;

@property (nonatomic, assign, readonly) BOOL isBottleneck;
@property (nonatomic, retain) TDCounter *startCounter;
@property (nonatomic, retain) TDCounter *finishCounter;
@end

