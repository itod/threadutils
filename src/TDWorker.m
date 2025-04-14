//
//  TDWorker.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import "TDWorker.h"
#import <TDThreadUtils/TDRunnable.h>
#import <TDThreadUtils/TDChannel.h>

@interface TDWorker ()
@property (nonatomic, retain) id <TDRunnable>runnable;
@property (nonatomic, retain) id <TDChannel>inputChannel;
@property (nonatomic, retain) id <TDChannel>outputChannel;
@end

@implementation TDWorker

+ (TDWorker *)workerWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc {
    return [[[self alloc] initWithRunnable:runnable inputChannel:ic outputChannel:oc] autorelease];
}


- (instancetype)initWithRunnable:runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc {
    self = [super init];
    if (self) {
        self.runnable = runnable;
        self.inputChannel = ic;
        self.outputChannel = oc;
    }
    return self;
}


- (void)dealloc {
    self.runnable = nil;
    self.inputChannel = nil;
    self.outputChannel = nil;
    [super dealloc];
}




@end
