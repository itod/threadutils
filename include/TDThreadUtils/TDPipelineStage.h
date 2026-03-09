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
+ (TDPipelineStage *)pipelineStageWithRunnableClass:(Class)cls runnerCount:(NSUInteger)c;
- (instancetype)initWithRunnableClass:(Class)cls runnerCount:(NSUInteger)c;

@property (nonatomic, assign, readonly) TDPipelineStageType type;
@property (nonatomic, retain, readonly) Class runnableClass;

@property (nonatomic, assign, readonly) NSUInteger runnerCount;
@property (nonatomic, copy, readonly) NSArray<TDRunner *> *runners;

@property (nonatomic, retain, readonly) id <TDChannel>inputChannel;
@property (nonatomic, retain, readonly) id <TDChannel>outputChannel;

@property (nonatomic, assign) id <TDPipelineStageDelegate>delegate;

@property (nonatomic, assign, readonly) BOOL isBottleneck;
@property (nonatomic, retain) TDCounter *startCounter;
@property (nonatomic, retain) TDCounter *finishCounter;
@end

