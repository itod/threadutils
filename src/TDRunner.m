//
//  TDRunner.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDRunner.h>
#import <TDThreadUtils/TDRunnable.h>
#import <TDThreadUtils/TDChannel.h>
#import <TDThreadUtils/TDTrigger.h>

@interface TDRunner ()
@property (nonatomic, retain) id <TDChannel>inputChannel;
@property (nonatomic, retain) id <TDChannel>outputChannel;
@property (nonatomic, assign) NSUInteger number;
@end

@implementation TDRunner

+ (TDRunner *)runnerWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i {
    return [[[self alloc] initWithInputChannel:ic outputChannel:oc number:i] autorelease];
}


- (instancetype)initWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i {
    self = [super init];
    if (self) {
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

    self.titleText = nil;
    self.infoText = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@ B?:%d>", [self class], self, _runnable, [[_runnable class] isBottleneck]];
}


#pragma mark -
#pragma mark Public

- (void)runWithStartTrigger:(TDTrigger *)startTrigger doneTrigger:(TDTrigger *)doneTrigger {
    NSAssert(_inputChannel, @"");
    
    self.progress = 0.0;
    
    if (startTrigger) {
        NSLog(@"BOTTLENECK WAITING");
        NSLog(@"%@ waiting on trigger: %@", self, startTrigger);
        [startTrigger await];
        NSLog(@"BOTTLENECK DONE WAITING");
        NSLog(@"%@", self);
    }
    
    for (;;) {
        id input = [_inputChannel take];
        
        NSAssert(_runnable, @"");
        
        id output = nil;
        BOOL stop = NO;
        
        if ([NSNull null] == input) {
            output = input;
            stop = YES;
        } else {
            NSError *err = nil;
            output = [_runnable runWithInput:input error:&err];
            if (err) {
                NSLog(@"%@", err);
                NSAssert(0, @"");
                return;
            }
        }
        
        NSAssert(_outputChannel, @"");
        [_outputChannel put:output];
        
        if (stop) {
            if (doneTrigger) {
                // -join
                NSLog(@"BOTTLENECK REACHED. CAN BEGIN");
                NSLog(@"%@ firing trigger: %@", self, doneTrigger);
                [doneTrigger fire];
            }
            break;
        }
    }
}


#pragma mark -
#pragma mark TDRunnableDelegate

- (void)runnable:(TDRunnable *)r updateProgress:(double)d {
    NSAssert(_runnable == r, @"");
    self.progress = d;
}


- (void)runnable:(TDRunnable *)r updateTitleText:(NSString *)title infoText:(NSString *)info {
    NSAssert(_runnable == r, @"");
    self.titleText = title;
    self.infoText = info;
}

@end
