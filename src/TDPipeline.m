//
//  TDPipeline.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPipeline.h>
#import <TDThreadUtils/TDBoundedBuffer.h>
#import <TDThreadUtils/TDLinkedQueue.h>
#import <TDThreadUtils/TDTrigger.h>
#import <TDThreadUtils/TDRunnable.h>

@interface TDPipelineStage ()
- (void)setUpWithItemCount:(NSUInteger)itemCount inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc startTrigger:(TDTrigger *)startTrigger doneTrigger:(TDTrigger *)doneTrigger;
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
    
    self.delegate = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (BOOL)runWithError:(NSError **)outErr {
    BOOL success = YES;
    
    self.launcherProgress = 0.0;
    self.receiverProgress = 0.0;

    id <TDChannel>ic = [[self newBoundedBuffer] autorelease];
    id <TDChannel>oc = nil;
    
    id <TDChannel>countChannel = [TDBoundedBuffer boundedBufferWithSize:1];

    [NSThread detachNewThreadWithBlock:^{
        NSAssert(_launcher, @"");
        
        NSArray *items = [_launcher launchWithPipeline:self];
        NSUInteger count = items.count;
        [countChannel put:@(count)];
        
        NSUInteger i = 0;
        for (id item in items) {
            [ic put:item]; // yes ic of first stage is the oc for launcher.
            self.launcherProgress = (++i / count);
        }
        NSLog(@"LAUNCHER DONE!!!");
    }];
    
    NSUInteger count = [[countChannel take] unsignedIntegerValue];
    [countChannel put:@(count)];

    NSAssert(_stages, @"");
    NSEnumerator *en = [_stages objectEnumerator];
    TDPipelineStage *currStage = [en nextObject];
    TDPipelineStage *nextStage = nil;
    
    TDTrigger *doneTrigger = nil;
    TDTrigger *startTrigger = nil;
    
    while (currStage) {
        nextStage = [en nextObject];
        
        currStage.delegate = self;

        if (nextStage.isBottleneck)  {
            NSLog(@"NEXT STAGE IS BOTTLENECK");
            NSLog(@"CURR: %@", currStage);
            NSLog(@"NEXT: %@", nextStage);
            oc = [[self newLinkedQueue] autorelease];
            doneTrigger = [TDTrigger trigger];
        } else {
            oc = [[self newBoundedBuffer] autorelease];
            doneTrigger = nil;
        }
        
        [currStage setUpWithItemCount:count-1 inputChannel:ic outputChannel:oc startTrigger:startTrigger doneTrigger:doneTrigger];
        
        ic = oc;
        startTrigger = doneTrigger;

        currStage = nextStage;
    }
    
//    for (TDPipelineStage *stage in _stages) {
//        stage.delegate = self;
//        
//        oc = [[self newBoundedBuffer] autorelease];
//
//        [stage setUpWithInputChannel:ic outputChannel:oc];
//        
//        ic = oc;
//    }
    
    TDTrigger *receiverDoneTrigger = [TDTrigger trigger];

    [NSThread detachNewThreadWithBlock:^{
        NSAssert(_receiver, @"");
        
        NSUInteger count = [[countChannel take] unsignedIntegerValue];
        
        NSUInteger i = 0;
        while (i < count) {
            id item = [oc take]; // yes oc of last stage is the ic for receiver.
            [_receiver receiveItem:item withPipeline:self];
            
            self.receiverProgress = (++i / count);
        }
        
        [_receiver doneWithPipeline:self];
        NSLog(@"RECEIVER DONE!!!");
        [receiverDoneTrigger fire];
    }];
    
    // wait until receiver is done
    [receiverDoneTrigger await];
    
    return success;
}


#pragma mark -
#pragma mark Private

- (id <TDChannel>)newBoundedBuffer {
    return [[TDBoundedBuffer alloc] initWithSize:5]; // TODO how to configure this?
}


- (id <TDChannel>)newLinkedQueue {
    return [TDLinkedQueue linkedQueue];
}


#pragma mark -
#pragma mark TDPipelineStageDelegate

- (void)pipelineStageProgressDidUpdate:(TDPipelineStage *)ps {
    NSAssert([_stages containsObject:ps], @"");
    if (_delegate) {
        [(id)_delegate performSelectorOnMainThread:@selector(pipelineProgressDidUpdate:) withObject:self waitUntilDone:NO];
    }
}

@end
