//
//  TDPipeline.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipeline.h>
#import <TDThreadUtils/TDPipelineStage.h>
#import <TDThreadUtils/TDBoundedBuffer.h>

@interface TDPipelineStage ()
- (void)setUpWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc;
@end

@interface TDPipeline ()
@property (nonatomic, retain, readwrite) id <TDLauncher>launcher;
@property (nonatomic, retain, readwrite) id <TDReceiver>receiver;
@property (nonatomic, copy, readwrite) NSArray <TDPipelineStage *>*stages;
@end

@implementation TDPipeline

+ (TDPipeline *)pipleineWithLauncher:(id <TDLauncher>)l receiver:(id <TDReceiver>)r stages:(NSArray *)stages {
    return [[[self alloc] initWithLauncher:l receiver:r stages:stages] autorelease];
}


- (instancetype)initWithLauncher:(id <TDLauncher>)l receiver:(id <TDReceiver>)r stages:(NSArray *)stages {
    self = [super init];
    if (self) {
        self.launcher = l;
        self.receiver = r;
        self.stages = stages;
    }
    return self;
}


- (void)dealloc {
    self.launcher = nil;
    self.receiver = nil;
    self.stages = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (BOOL)runWithError:(NSError **)outErr {
    BOOL success = YES;

    id <TDChannel>ic = [[self newChannel] autorelease];
    id <TDChannel>oc = nil;

    NSAssert(_stages, @"");
    for (TDPipelineStage *stage in _stages) {
        oc = [[self newChannel] autorelease];
        
        [stage setUpWithInputChannel:ic outputChannel:oc];
        
        ic = oc;
    }
    
    oc = _stages.firstObject.inputChannel; // yes ic of first stage is the oc for launcher.
    ic = _stages.lastObject.outputChannel; // yes oc of last stage is the ic for receiver.

    [NSThread detachNewThreadWithBlock:^{
        NSAssert(_launcher, @"");
        [_launcher launchWithOutputChannel:oc];
    }];

    [NSThread detachNewThreadWithBlock:^{
        NSAssert(_receiver, @"");
        [_receiver receiveWithInputChannel:ic];
    }];

    return success;
}


#pragma mark -
#pragma mark Private

- (id <TDChannel>)newChannel {
    return [[TDBoundedBuffer alloc] initWithSize:5]; // TODO how to configure this?
}

@end
