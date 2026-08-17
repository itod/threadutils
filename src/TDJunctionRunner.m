//
//  TDJunctionRunner.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 8/17/26.
//  Copyright © 2026 Todd Ditchendorf. All rights reserved.
//

#import "TDJunctionRunner.h"
#import <TDThreadUtils/TDWorker.h>
#import <TDThreadUtils/TDChannel.h>
#import <TDThreadUtils/TDCounter.h>

@interface TDRunner ()
@property (nonatomic, retain) id <TDChannel>inputChannel;
@property (nonatomic, retain) id <TDChannel>outputChannel;
@end

@interface TDJunctionRunner ()
@property (nonatomic, retain) NSMutableArray *buffer;
@end

@implementation TDJunctionRunner


- (void)dealloc {
    self.buffer = nil;
    [super dealloc];
}


- (void)runWithStartCounter:(TDCounter *)startCounter finishCounter:(TDCounter *)finishCounter {
    NSAssert(self.inputChannel, @"");
    NSAssert(finishCounter, @"");

    self.progress = 0.0;
    
    [startCounter await];
    
    self.buffer = [NSMutableArray array];
    
    for (;;) {
        id input = [[[self.inputChannel take] retain] autorelease];
        
        NSAssert(self.worker, @"");
        
        NSError *err = nil;
        id output = nil;
        
        @autoreleasepool {
            output = [[self.worker runWithInput:input error:&err] retain]; // +1
        }
        
        [output autorelease]; // -1
        
        if (err) {
            NSLog(@"%@", err);
            NSAssert(0, @"");
            return;
        }
        
        [finishCounter increment];
        
        [_buffer addObject:output];
        
        if ([finishCounter attempt]) {
            break; // junciton bottleneck complete. now perform the transformation below…
        }
    }
    
    NSError *err = nil;
    NSArray *items = [self.worker handleJunctionWithItems:_buffer error:&err];

    if (err) {
        NSLog(@"%@", err);
        NSAssert(0, @"");
        return;
    }

    // …and carry on with the new shape of the pipeline
    
    NSAssert(self.outputChannel, @"");
    for (id item in items) {
        [self.outputChannel put:item];
    }
}

@end
