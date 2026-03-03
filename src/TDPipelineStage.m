//
//  TDPipelineStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipelineStage.h>
#import <TDThreadUtils/TDRunnable.h>
#import <TDThreadUtils/TDTrigger.h>
#import "TDRunner.h"

@interface TDPipelineStage ()
@property (nonatomic, assign, readwrite) TDPipelineStageType type;
@property (nonatomic, retain, readwrite) Class workerClass;

@property (nonatomic, assign, readwrite) NSUInteger runnerCount;
@property (nonatomic, copy, readwrite) NSArray<TDRunner *> *runners;

@property (atomic, assign, readwrite) NSUInteger itemCount;

// Stage private API
- (void)setUpWithItemCount:(NSUInteger)c inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc sinkChannel:(id <TDChannel>)sc;
@property (nonatomic, retain, readwrite) id <TDChannel>inputChannel;
@property (nonatomic, retain, readwrite) id <TDChannel>outputChannel;
@property (nonatomic, retain, readwrite) id <TDChannel>sinkChannel;
@end

@implementation TDPipelineStage

+ (TDPipelineStage *)pipelineStageWithType:(TDPipelineStageType)type runnableClass:(Class)cls runnerCount:(NSUInteger)c {
    return [[[self alloc] initWithType:type runnableClass:cls runnerCount:c] autorelease];
}


- (instancetype)initWithType:(TDPipelineStageType)type runnableClass:(Class)cls runnerCount:(NSUInteger)c {
    self = [super init];
    if (self) {
        self.type = type;
        self.workerClass = cls;
        self.runnerCount = c;
    }
    return self;
}


- (void)dealloc {
    self.delegate = nil;
    self.workerClass = nil;
    self.runners = nil;

    self.inputChannel = nil;
    self.outputChannel = nil;
    self.sinkChannel = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private

- (void)setUpWithItemCount:(NSUInteger)c inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc sinkChannel:(id <TDChannel>)sc {
    NSAssert(ic, @"");
    NSAssert(oc, @"");

    self.itemCount = c;
    self.inputChannel = ic;
    self.outputChannel = oc;
    self.sinkChannel = sc;

    NSMutableArray *runners = [NSMutableArray arrayWithCapacity:_runnerCount];
    
    //NSUInteger thresholdCount = 1; // 1 for -await above
    
    for (NSUInteger i = 0; i < _runnerCount; ++i) {
        TDRunner *runner = [TDRunner runnerWithInputChannel:ic outputChannel:oc sinkChannel:sc number:i+1];
        TDRunnable *runnable = [[[_workerClass alloc] initWithDelegate:runner] autorelease];
        runner.runnable = runnable;
        
        [runner addObserver:self forKeyPath:@"progress" options:0 context:NULL];
        [runners addObject:runner];
    }
    
    self.runners = runners;
    
    TDTrigger *sinkDoneTrigger = nil;
    if ([_workerClass wantsSink]) {
        sinkDoneTrigger = [TDTrigger trigger];
    }
    
    for (TDRunner *runner in _runners) {
        [NSThread detachNewThreadWithBlock:^{
            [runner run];
        }];
        if ([_workerClass wantsSink]) {
            [NSThread detachNewThreadWithBlock:^{
                [runner runSink:_itemCount];
                [sinkDoneTrigger fire];
            }];
        }
    }
    
    [sinkDoneTrigger await];
}


#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)obj change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)ctx {
    NSAssert([_runners containsObject:obj], @"");
    [_delegate pipelineStageProgressDidUpdate:self];
}

@end
