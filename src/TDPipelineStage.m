//
//  TDPipelineStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipelineStage.h>
#import <TDThreadUtils/TDRunnable.h>
#import "Runner.h"

@interface TDPipelineStage ()
@property (nonatomic, retain, readwrite) Class workerClass;
@property (nonatomic, assign, readwrite) NSUInteger threadCount;

@property (nonatomic, copy) NSArray<Runner *> *runners;

// Stage private API
- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc;
@property (nonatomic, retain, readwrite) id <TDChannel>inputChannel;
@property (nonatomic, retain, readwrite) id <TDChannel>outputChannel;
@end

@implementation TDPipelineStage

+ (TDPipelineStage *)pipelineStageWithRunnableClass:(Class)cls threadCount:(NSUInteger)c {
    return [[[self alloc] initWithRunnableClass:cls threadCount:c] autorelease];
}


- (instancetype)initWithRunnableClass:(Class)cls threadCount:(NSUInteger)c {
    self = [super init];
    if (self) {
        self.workerClass = cls;
        self.threadCount = c;
    }
    return self;
}


- (void)dealloc {
    self.workerClass = nil;
    self.inputChannel = nil;
    self.outputChannel = nil;
    
    self.runners = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private

- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc {
    self.inputChannel = ic;
    self.outputChannel = oc;
    
    NSMutableArray *runners = [NSMutableArray arrayWithCapacity:_threadCount];
    
    for (NSUInteger i = 0; i < _threadCount; ++i) {
        id <TDRunnable>runnable = [[[_workerClass alloc] init] autorelease];
        
        Runner *runner = [Runner runnerWithRunnable:runnable inputChannel:ic outputChannel:oc number:i+1];
        [runners addObject:runner];
        
        [NSThread detachNewThreadWithBlock:^{
            [runner run];
        }];
    }
    
    self.runners = runners;
}

@end
