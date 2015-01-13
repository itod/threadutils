//
//  TDThreshold.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDThreshold.h>
#import <TDThreadUtils/TDSemaphore.h>

@interface TDSemaphore ()
- (void)lock;
- (void)unlock;

- (void)decrement;
- (void)increment;

- (BOOL)available;
- (void)wait;

@property (assign) NSInteger value;
@property (retain) NSCondition *monitor;
@end

@implementation TDThreshold

+ (instancetype)thresholdWithValue:(NSInteger)value {
    return [[[self alloc] initWithValue:value] autorelease];
}


#pragma mark -
#pragma mark TDSync 

- (void)acquire {
    [[self retain] autorelease];
    [self lock];
    
    [self decrement];

    if (![self available]) {
        [self broadcast];
    } else {
        while ([self available]) {
            [self wait];
        }
    }

    [self unlock];
}


- (void)relinquish {
    NSAssert(0, @"should never call");
}


#pragma mark -
#pragma mark Private

- (void)increment {
    NSAssert(0, @"should never call");
}


- (void)broadcast {
    NSAssert(self.monitor, @"");
    [self.monitor broadcast];
}

@end
