//
//  TDPipeline.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDThreadUtils/TDPipelineStage.h>

@protocol TDChannel;
@class TDPipeline;

@protocol TDPipelineDelegate <NSObject>
// this will always be called on main thread
- (void)pipelineProgressDidUpdate:(TDPipeline *)p;
@end

@protocol TDLauncher <NSObject>
- (void)launchWithPipeline:(TDPipeline *)p outputChannel:(id <TDChannel>)channel;
@end

@protocol TDReceiver <NSObject>
- (void)receiveWithPipeline:(TDPipeline *)p inputChannel:(id <TDChannel>)channel;
@end

@interface TDPipeline : NSObject <TDPipelineStageDelegate>

+ (TDPipeline *)pipleineWithLauncher:(id <TDLauncher>)l receiver:(id <TDReceiver>)r stages:(NSArray *)stages;
- (instancetype)initWithLauncher:(id <TDLauncher>)l receiver:(id <TDReceiver>)r stages:(NSArray *)stages;

@property (nonatomic, retain, readonly) id <TDLauncher>launcher;
@property (nonatomic, retain, readonly) id <TDReceiver>receiver;
@property (nonatomic, copy, readonly) NSArray *stages;

@property (nonatomic, assign) id <TDPipelineDelegate>delegate;

@property (nonatomic, assign) double launcherProgress;
@property (nonatomic, assign) double receiverProgress;

- (BOOL)runWithError:(NSError **)outErr;

@end
