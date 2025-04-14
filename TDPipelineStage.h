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

+ (TDPipelineStage *)pipelineStageWithRunnableClass:(Class)cls workerCount:(NSUInteger)c;
- (instancetype)initWithRunnableClass:(Class)cls workerCount:(NSUInteger)c;

@property (nonatomic, retain, readonly) Class workerClass;
@property (nonatomic, assign, readonly) NSUInteger workerCount;

@property (nonatomic, retain, readonly) id <TDChannel>inputChannel;
@property (nonatomic, retain, readonly) id <TDChannel>outputChannel;

@end

