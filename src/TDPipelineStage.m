//
//  TDPipelineStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipelineStage.h>
#import <TDThreadUtils/TDRunnable.h>
#import <TDThreadUtils/TDChannel.h>
#import <TDThreadUtils/TDTrigger.h>
#import "TDRunner.h"

@interface TDPipelineStage ()
@property (nonatomic, retain, readwrite) Class runnableClass;
@property (nonatomic, assign, readwrite) NSUInteger runnerCount;
@property (nonatomic, copy, readwrite) NSArray<TDRunner *> *runners;

@property (nonatomic, retain, readwrite) id <TDChannel>inputChannel;
@property (nonatomic, retain, readwrite) id <TDChannel>outputChannel;
@end

@implementation TDPipelineStage

+ (TDPipelineStage *)pipelineStageWithRunnableClass:(Class)cls runnerCount:(NSUInteger)c {
    return [[[self alloc] initWithRunnableClass:cls runnerCount:c] autorelease];
}


- (instancetype)initWithRunnableClass:(Class)cls runnerCount:(NSUInteger)c {
    self = [super init];
    if (self) {
        self.runnableClass = cls;
        self.runnerCount = c;
    }
    return self;
}


- (void)dealloc {
    self.delegate = nil;
    self.runnableClass = nil;
    self.runners = nil;

    self.inputChannel = nil;
    self.outputChannel = nil;
    self.startTrigger = nil;
    self.doneTrigger = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@ (%lu) B?:%d>", [self class], self, _runnableClass, _runnerCount, self.isBottleneck];
}


- (BOOL)isBottleneck {
    NSAssert(_runnableClass, @"");
    return [_runnableClass isBottleneck];
}


#pragma mark -
#pragma mark Private

- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc startTrigger:(TDTrigger *)startTrigger doneTrigger:(TDTrigger *)doneTrigger {
    NSAssert(ic, @"");
    NSAssert(oc, @"");

    self.inputChannel = ic;
    self.outputChannel = oc;
    
    self.startTrigger = startTrigger;
    self.doneTrigger = doneTrigger;

    NSMutableArray *runners = [NSMutableArray arrayWithCapacity:_runnerCount];
        
    for (NSUInteger i = 0; i < _runnerCount; ++i) {
        TDRunner *runner = [TDRunner runnerWithInputChannel:ic outputChannel:oc number:i+1];
        TDRunnable *runnable = [[[_runnableClass alloc] initWithDelegate:runner] autorelease];
        runner.runnable = runnable;
        
        [runner addObserver:self forKeyPath:@"progress" options:0 context:NULL];
        [runners addObject:runner];
    }
    
    self.runners = runners;
    
    for (TDRunner *runner in _runners) {
        [NSThread detachNewThreadWithBlock:^{
            [runner runWithStartTrigger:startTrigger doneTrigger:doneTrigger];
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
