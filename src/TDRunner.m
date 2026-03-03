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

@interface TDRunner ()
@property (nonatomic, retain) id <TDChannel>inputChannel;
@property (nonatomic, retain) id <TDChannel>outputChannel;
@property (nonatomic, retain) id <TDChannel>sinkChannel;
@property (nonatomic, assign) NSUInteger number;
@end

@implementation TDRunner

+ (TDRunner *)runnerWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc sinkChannel:(id <TDChannel>)sc number:(NSUInteger)i {
    return [[[self alloc] initWithInputChannel:ic outputChannel:oc sinkChannel:sc number:i] autorelease];
}


- (instancetype)initWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc sinkChannel:(id <TDChannel>)sc number:(NSUInteger)i {
    self = [super init];
    if (self) {
        self.inputChannel = ic;
        self.outputChannel = oc;
        self.sinkChannel = sc;
        self.number = i;
    }
    return self;
}


- (void)dealloc {
    self.runnable = nil;
    self.inputChannel = nil;
    self.outputChannel = nil;
    self.sinkChannel = nil;

    self.titleText = nil;
    self.infoText = nil;
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

- (void)runnable:(TDRunnable *)r updateProgress:(double)d {
    NSAssert(_runnable == r, @"");
    self.progress = d;
}


- (void)runnable:(TDRunnable *)r updateTitleText:(NSString *)title infoText:(NSString *)info {
    NSAssert(_runnable == r, @"");
    self.titleText = title;
    self.infoText = info;
}


- (void)runnable:(TDRunnable *)r sendToSink:(id)data {
    NSAssert(_sinkChannel, @"");
    [_sinkChannel put:data];
}

@end
