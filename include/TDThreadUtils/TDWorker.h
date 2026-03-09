//
//  TDWorker.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipeline.h>

@class TDWorker;

@protocol TDWorkerDelegate <NSObject>
- (void)runnable:(TDWorker *)r updateProgress:(double)d;
- (void)runnable:(TDWorker *)r updateTitleText:(NSString *)title infoText:(NSString *)info;
@end

@interface TDWorker : NSObject

+ (TDPipelineStageType)pipelineStageType;

// designated initializer
- (instancetype)initWithDelegate:(id <TDWorkerDelegate>)d;

// main pipeline channel
- (id)runWithInput:(id)input error:(NSError **)outErr;

@property (nonatomic, assign, readonly) id <TDWorkerDelegate>delegate;

@end
