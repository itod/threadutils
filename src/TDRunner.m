//
//  TDRunner.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDRunner.h>
#import <TDThreadUtils/TDWorker.h>
#import <TDThreadUtils/TDChannel.h>
#import <TDThreadUtils/TDCounter.h>

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
    self.worker = nil;
    self.inputChannel = nil;
    self.outputChannel = nil;

    self.titleText = nil;
    self.infoText = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@>", [self class], self, _worker];
}


#pragma mark -
#pragma mark Public

- (void)runWithStartCounter:(TDCounter *)startCounter finishCounter:(TDCounter *)finishCounter {
    NSAssert(_inputChannel, @"");
    
    self.progress = 0.0;
    
    [startCounter await];
    
    for (;;) {
        id input = [_inputChannel take];
        
        NSAssert(_worker, @"");
        
        NSError *err = nil;
        id output = nil;
        
        @autoreleasepool {
            output = [[_worker runWithInput:input error:&err] retain]; // +1
        }
        
        [finishCounter increment];

        if (err) {
            NSLog(@"%@", err);
            NSAssert(0, @"");
            return;
        }
        
        NSAssert(_outputChannel, @"");
        [_outputChannel put:[output autorelease]]; // -1
    }
}


#pragma mark -
#pragma mark TDWorkerDelegate

- (void)runnable:(TDWorker *)r updateProgress:(double)d {
    NSAssert(_worker == r, @"");
    self.progress = d;
}


- (void)runnable:(TDWorker *)r updateTitleText:(NSString *)title infoText:(NSString *)info {
    NSAssert(_worker == r, @"");
    self.titleText = title;
    self.infoText = info;
}

@end
