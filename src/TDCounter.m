//
//  TDCounter.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/31/13.
//  Copyright (c) 2013 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDCounter.h>

@interface TDCounter ()
@property (assign) NSInteger value;
@property (retain) NSCondition *monitor;
@end

@implementation TDCounter

+ (instancetype)counterWithValue:(NSInteger)value {
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
    return [NSString stringWithFormat:@"<%@ %p (Remaining: %ld)>", [self class], self, _value];
}


#pragma mark -
#pragma mark Public

- (BOOL)attempt {
    [[self retain] autorelease];
    
    [self lock];
    
    BOOL success = [self available];
    
    if (success) {
        [self down];
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
        [self down];
    }

    [self unlock];
    
    return success;
}


- (void)await {
    [[self retain] autorelease];
    [self lock];
    
    while (![self available]) {
        [self wait];
    }
    
    [self unlock];
}


- (void)increment {
    [[self retain] autorelease];
    [self lock];
    [self down];

    if ([self available]) {
        [self signal];
    }
    
    [self unlock];
}


#pragma mark -
#pragma mark Private Business

- (void)down {
    self.value--;
}


- (BOOL)available {
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
