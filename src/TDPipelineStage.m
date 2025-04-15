//
//  TDPipelineStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipelineStage.h>
#import <TDThreadUtils/TDRunnable.h>
#import "TDRunner.h"

@interface TDPipelineStage ()
@property (nonatomic, assign, readwrite) TDPipelineStageType type;
@property (nonatomic, retain, readwrite) Class workerClass;
@property (nonatomic, assign, readwrite) NSUInteger threadCount;

@property (nonatomic, copy) NSArray<TDRunner *> *runners;

// Stage private API
- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc;
@property (nonatomic, retain, readwrite) id <TDChannel>inputChannel;
@property (nonatomic, retain, readwrite) id <TDChannel>outputChannel;
@end

@implementation TDPipelineStage

+ (TDPipelineStage *)pipelineStageWithType:(TDPipelineStageType)type runnableClass:(Class)cls threadCount:(NSUInteger)c {
    return [[[self alloc] initWithType:type runnableClass:cls threadCount:c] autorelease];
}


- (instancetype)initWithType:(TDPipelineStageType)type runnableClass:(Class)cls threadCount:(NSUInteger)c {
    self = [super init];
    if (self) {
        self.type = type;
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
    
    self.delegate = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private

- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc {
    NSAssert(ic, @"");
    NSAssert(oc, @"");

    self.inputChannel = ic;
    self.outputChannel = oc;
    
    NSMutableArray *runners = [NSMutableArray arrayWithCapacity:_threadCount];
    
    for (NSUInteger i = 0; i < _threadCount; ++i) {
        id <TDRunnable>runnable = [[[_workerClass alloc] init] autorelease];
        
        TDRunner *runner = [TDRunner runnerWithRunnable:runnable inputChannel:ic outputChannel:oc number:i+1];
        runnable.delegate = runner;
        
        [runner addObserver:self forKeyPath:@"progress" options:0 context:NULL];
        [runners addObject:runner];
    }
    
    self.runners = runners;
    
    for (TDRunner *runner in _runners) {
        [NSThread detachNewThreadWithBlock:^{
            [runner run];
        }];
    }
}


#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)path ofObject:(id)obj change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)ctx {
    NSAssert([_runners containsObject:obj], @"");
    [_delegate pipelineStageProgressDidUpdate:self];
}

@end
