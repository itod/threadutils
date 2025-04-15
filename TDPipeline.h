//
//  TDPipeline.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDChannel;
@class TDPipeline;

@protocol TDPipelineDelegate <NSObject>
- (void)pipelineProgressUpdated:(TDPipeline *)p;
@end

@protocol TDLauncher <NSObject>
- (void)launchWithOutputChannel:(id <TDChannel>)channel;
@end

@protocol TDReceiver <NSObject>
- (void)receiveWithInputChannel:(id <TDChannel>)channel;
@end

@interface TDPipeline : NSObject

+ (TDPipeline *)pipleineWithLauncher:(id <TDLauncher>)l receiver:(id <TDReceiver>)r stages:(NSArray *)stages;
- (instancetype)initWithLauncher:(id <TDLauncher>)l receiver:(id <TDReceiver>)r stages:(NSArray *)stages;

@property (nonatomic, retain, readonly) id <TDLauncher>launcher;
@property (nonatomic, retain, readonly) id <TDReceiver>receiver;
@property (nonatomic, copy, readonly) NSArray *stages;

@property (nonatomic, assign) id <TDPipelineDelegate>delegate;

- (BOOL)runWithError:(NSError **)outErr;

@end
