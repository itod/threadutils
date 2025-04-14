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
//@property (nonatomic, retain, readwrite) id <TDChannel>inputChannel;
//@property (nonatomic, retain, readwrite) id <TDChannel>outputChannel;
@end

@interface TDPipeline ()
@property (nonatomic, copy, readwrite) NSArray *stages;
@end

@implementation TDPipeline

+ (TDPipeline *)pipleineWithStages:(NSArray *)stages {
    return [[[self alloc] initWithStages:stages] autorelease];
}


- (instancetype)initWithStages:(NSArray *)stages {
    self = [super init];
    if (self) {
        self.stages = stages;
    }
    return self;
}


- (void)dealloc {
    self.stages = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (BOOL)runWithError:(NSError **)outErr {
    BOOL success = YES;
    
    id <TDChannel>ic = nil;
    id <TDChannel>oc = [[self newChannel] autorelease];

    NSUInteger i = _stages.count;
    for (TDPipelineStage *stage in _stages) {
        BOOL isLast = --i == 0;
        
        [stage setUpWithInputChannel:ic outputChannel:oc];
        
        ic = oc;
        oc = isLast ? nil : [[self newChannel] autorelease];
    }
    
    
    
    return success;
}


#pragma mark -
#pragma mark Private

- (id <TDChannel>)newChannel {
    return [[TDBoundedBuffer alloc] initWithSize:5];
}

@end
