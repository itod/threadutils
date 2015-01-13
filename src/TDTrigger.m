//
//  TDTrigger.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDTrigger.h>
#import <TDThreadUtils/TDSemaphore.h>

@interface TDTrigger ()
- (void)lock;
- (void)unlock;

- (BOOL)fired;
- (void)wait;

@property (assign) BOOL flag;
@property (retain) NSCondition *monitor;
@end

@implementation TDTrigger

+ (instancetype)trigger {
    return [[[self alloc] init] autorelease];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.flag = NO;
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
    
    while (![self fired]) {
        [self wait];
    }
    
    [self unlock];
}


- (void)fire {
    [[self retain] autorelease];
    [self lock];
    
    self.flag = YES;
    
    [self broadcast];
    
    [self unlock];
}


#pragma mark -
#pragma mark Private Business

- (BOOL)fired {
    return _flag;
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
