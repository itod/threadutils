//
//  TDThreshold.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDThreshold.h>
#import <TDThreadUtils/TDSemaphore.h>

@interface TDThreshold ()
- (void)lock;
- (void)unlock;

- (void)decrement;

- (BOOL)reached;
- (void)wait;

@property (assign) NSInteger value;
@property (retain) NSCondition *monitor;
@end

@implementation TDThreshold

+ (instancetype)thresholdWithValue:(NSInteger)value {
    return [[[self alloc] initWithValue:value] autorelease];
}


- (instancetype)initWithValue:(NSInteger)value {
    self = [super init];
    if (self) {
        self.value = value;
        self.monitor = [[[NSCondition alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.monitor = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark TDSync 

- (void)await {
    [[self retain] autorelease];
    [self lock];
    
    [self decrement];

    if ([self reached]) {
        [self broadcast];
    }
    
    while (![self reached]) {
        [self wait];
    }

    [self unlock];
}


#pragma mark -
#pragma mark Private Business

- (void)decrement {
    self.value--;
}


- (BOOL)reached {
    return _value <= 0;
}


#pragma mark -
#pragma mark Private Convenience

- (void)lock {
    NSAssert(_monitor, @"");
    [_monitor lock];
}


- (void)unlock {
    NSAssert(_monitor, @"");
    [_monitor unlock];
}


- (void)wait {
    NSAssert(_monitor, @"");
    [_monitor wait];
}


- (void)broadcast {
    NSAssert(_monitor, @"");
    [_monitor broadcast];
}

@end
