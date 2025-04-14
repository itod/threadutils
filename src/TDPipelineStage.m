//
//  TDPipelineStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipelineStage.h>
#import <TDThreadUtils/TDRunnable.h>
#import "TDWorker.h"

@interface TDPipelineStage ()
@property (nonatomic, retain, readwrite) Class workerClass;
@property (nonatomic, assign, readwrite) NSUInteger workerCount;

@property (nonatomic, copy) NSArray<TDWorker *> *workers;

// Stage private API
- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc;
@property (nonatomic, retain, readwrite) id <TDChannel>inputChannel;
@property (nonatomic, retain, readwrite) id <TDChannel>outputChannel;
@end

@implementation TDPipelineStage

+ (TDPipelineStage *)pipelineStageWithRunnableClass:(Class)cls workerCount:(NSUInteger)c {
    return [[[self alloc] initWithRunnableClass:cls workerCount:c] autorelease];
}


- (instancetype)initWithRunnableClass:(Class)cls workerCount:(NSUInteger)c {
    self = [super init];
    if (self) {
        self.workerClass = cls;
        self.workerCount = c;
    }
    return self;
}


- (void)dealloc {
    self.workerClass = nil;
    self.inputChannel = nil;
    self.outputChannel = nil;
    
    self.workers = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Private

- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc {
    self.inputChannel = ic;
    self.outputChannel = oc;
    
    NSMutableArray *workers = [NSMutableArray arrayWithCapacity:_workerCount];
    
    for (NSUInteger i = 0; i < _workerCount; ++i) {
        id <TDRunnable>runnable = [[[_workerClass alloc] init] autorelease];
        
        TDWorker *worker = [TDWorker workerWithRunnable:runnable inputChannel:ic outputChannel:oc];
        [workers addObject:worker];
    }
    
    self.workers = workers;
}

@end
