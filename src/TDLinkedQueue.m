//
//  TDLinkedQueue.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 10/21/17.
//  Copyright © 2017 Todd Ditchendorf. All rights reserved.
//

#import "TDLinkedQueue.h"

@interface LQNode : NSObject
@property (retain) id object;
@property (retain) LQNode *next;
@end

@implementation LQNode

- (instancetype)initWithObject:(id)obj {
    self = [super init];
    if (self) {
        self.object = obj;
    }
    return self;
}


- (void)dealloc {
    self.object = nil;
    self.next = nil;
    [super dealloc];
}

@end

@interface TDLinkedQueue ()
@property (nonatomic, retain) LQNode *head;
@property (nonatomic, retain) LQNode *last;

@property (retain) NSCondition *monitor;
@end

@implementation TDLinkedQueue

- (instancetype)init {
    self = [super init];
    if (self) {
        self.monitor = [[[NSCondition alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.head = nil;
    self.last = nil;
    
    self.monitor = nil;
    [super dealloc];
}


// -description is not thread safe!
- (NSString *)description {
    NSMutableString *buf = [NSMutableString string];
    
    LQNode *node = _head;
    
    while (node) {
        [buf appendFormat:@"%@%@", node.object, node.next ? @"->" : @""];
        node = node.next;
    }
    
    return [NSString stringWithFormat:@"<%@ %p %@>", [self class], self, buf];
}


- (void)put:(id)obj {
    NSParameterAssert(obj);

    LQNode *node = [[[LQNode alloc] initWithObject:obj] autorelease];
    
    [[self retain] autorelease];
    [self lock];
    
    if ([self available]) {
        _last.next = node;
        self.last = node;
    } else {
        self.head = node;
        self.last = node;
    }

    [self signal];
    [self unlock];
}


- (id)poll {
    [[self retain] autorelease];
    [self lock];
    
    id result = nil;

    if ([self available]) {
        result = [self doPoll];
    }

    [self unlock];
    
    return result;
}


- (id)take {
    [[self retain] autorelease];
    [self lock];
    
    while (![self available]) {
        [self wait];
    }
    
    id result = [self doPoll];

    [self unlock];
    
    return result;
}


- (id)takeBeforeDate:(NSDate *)limit {
    NSParameterAssert([self isValidDate:limit]);
    [[self retain] autorelease];
    
    [self lock];
    
    while ([self isValidDate:limit] && ![self available]) {
        [self waitUntilDate:limit];
    }
    
    id result = nil;
    
    if ([self available]) {
        result = [self doPoll];
    }
    
    [self unlock];
    
    return result;
}


#pragma mark -
#pragma mark Private Business

// PRE: Lock is held
- (id)doPoll {
    NSAssert(_head, @"");
    NSAssert(_last, @"");
    NSAssert(_head.object, @"");
    
    id result = [[_head.object retain] autorelease];
    self.head = [[[_head retain] autorelease] next];
    if (!_head) {
        self.last = nil;
    }
    return result;
}


- (BOOL)available {
    NSAssert((_head && _last) || (!_head && !_last), @"");
    return nil != _head;
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
