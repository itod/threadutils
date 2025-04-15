//
//  TDWorker.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import "TDRunner.h"
#import <TDThreadUtils/TDRunnable.h>
#import <TDThreadUtils/TDChannel.h>

@interface TDRunner ()
@property (nonatomic, retain) id <TDRunnable>runnable;
@property (nonatomic, retain) id <TDChannel>inputChannel;
@property (nonatomic, retain) id <TDChannel>outputChannel;
@property (nonatomic, assign) NSUInteger number;
@end

@implementation TDRunner

+ (TDRunner *)runnerWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i {
    return [[[self alloc] initWithRunnable:runnable inputChannel:ic outputChannel:oc number:i] autorelease];
}


- (instancetype)initWithRunnable:runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i {
    self = [super init];
    if (self) {
        self.runnable = runnable;
        self.inputChannel = ic;
        self.outputChannel = oc;
        self.number = i;
    }
    return self;
}


- (void)dealloc {
    self.runnable = nil;
    self.inputChannel = nil;
    self.outputChannel = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (void)run {
    NSAssert(_inputChannel, @"");
    
    self.progress = 0.0;
    
    for (;;) {
        id input = [_inputChannel take];

        NSAssert(_runnable, @"");
        NSError *err = nil;
        id output = [_runnable runWithInput:input error:&err];

        NSAssert(_outputChannel, @"");
        [_outputChannel put:output];
    }
}


#pragma mark -
#pragma mark TDRunnableDelegate

- (void)runnable:(id<TDRunnable>)r updateProgress:(double)d {
    NSAssert(_runnable == r, @"");
    self.progress = d;
}

@end
