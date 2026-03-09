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
#import <TDThreadUtils/TDCounter.h>
#import "TDRunner.h"
#import "TDBottleneckStage.h"

@interface TDPipelineStage ()
@property (nonatomic, retain, readwrite) Class runnableClass;
@property (nonatomic, assign, readwrite) NSUInteger runnerCount;
@property (nonatomic, copy, readwrite) NSArray<TDRunner *> *runners;

@property (nonatomic, retain, readwrite) id <TDChannel>inputChannel;
@property (nonatomic, retain, readwrite) id <TDChannel>outputChannel;
@end

@implementation TDPipelineStage

+ (TDPipelineStage *)bottleneckStage {
    return [[[TDBottleneckStage alloc] init] autorelease];
}


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
    self.startCounter = nil;
    self.finishCounter = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@ (%lu) B?:%d>", [self class], self, self.runnableClass, self.runnerCount, self.isBottleneck];
}


- (BOOL)isBottleneck {
    return NO;
}


#pragma mark -
#pragma mark Private

- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc startCounter:(TDCounter *)startCounter finishCounter:(TDCounter *)finishCounter {
    NSAssert(ic, @"");
    NSAssert(oc, @"");

    self.inputChannel = ic;
    self.outputChannel = oc;
    
    self.startCounter = startCounter;
    self.finishCounter = finishCounter;
    
    NSMutableArray *runners = [NSMutableArray arrayWithCapacity:self.runnerCount];
        
    for (NSUInteger i = 0; i < self.runnerCount; ++i) {
        TDRunner *runner = [TDRunner runnerWithInputChannel:ic outputChannel:oc number:i+1];
        TDRunnable *runnable = [[[self.runnableClass alloc] initWithDelegate:runner] autorelease];
        runner.runnable = runnable;
        
        [runner addObserver:self forKeyPath:@"progress" options:0 context:NULL];
        [runners addObject:runner];
    }
    
    self.runners = runners;

    for (TDRunner *runner in _runners) {
        [NSThread detachNewThreadWithBlock:^{
            [runner runWithStartCounter:startCounter finishCounter:finishCounter];
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
