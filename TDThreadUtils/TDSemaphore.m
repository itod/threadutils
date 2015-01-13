//
//  TDSemaphore.m
//  Thread Utils
//
//  Created by Todd Ditchendorf on 5/31/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDSemaphore.h>

@interface TDSemaphore ()
- (void)lock;
- (void)unlock;

- (void)decrement;
- (void)increment;

- (BOOL)available;
- (void)wait;
- (void)signal;

- (BOOL)isValidDate:(NSDate *)limit;

@property (assign) NSInteger value;
@property (retain) NSCondition *monitor;
@end

@implementation TDSemaphore

+ (instancetype)semaphoreWithValue:(NSInteger)value {
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


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %ld>", [self class], self, _value];
}


#pragma mark -
#pragma mark Public

- (BOOL)attempt {
    [[self retain] autorelease];
    
    [self lock];
    
    BOOL success = [self available];
    
    if (success) {
        [self decrement];
    }
    
    [self unlock];

    return success;
}


- (BOOL)attemptBeforeDate:(NSDate *)limit {
    NSParameterAssert([self isValidDate:limit]);
    [[self retain] autorelease];
    
    [self lock];
    
    while ([self isValidDate:limit] && ![self available]) {
        [self waitUntilDate:limit];
    }
    
    BOOL success = [self available];
    
    if (success) {
        [self decrement];
    }

    [self unlock];
    
    return success;
}


- (void)acquire {
    [[self retain] autorelease];
    [self lock];
    
    while (![self available]) {
        [self wait];
    }
    
    [self decrement];
    [self unlock];
}


- (void)relinquish {
    [[self retain] autorelease];
    [self lock];
    [self increment];

    if ([self available]) {
        [self signal];
    }
    
    [self unlock];
}


#pragma mark -
#pragma mark Private Business

- (void)decrement {
    self.value--;
}


- (void)increment {
    self.value++;
}


- (BOOL)available {
    return _value > 0;
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


- (void)waitUntilDate:(NSDate *)date {
    NSAssert(_monitor, @"");
    [_monitor waitUntilDate:date];
}


- (void)signal {
    NSAssert(_monitor, @"");
    [_monitor signal];
}


- (BOOL)isValidDate:(NSDate *)limit {
    NSParameterAssert(limit);
    return [limit timeIntervalSinceNow] > 0.0;
}

@end
