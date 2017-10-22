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

- (instancetype)init {
    self = [self initWithObject:nil];
    return self;
}


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

+ (instancetype)queue {
    return [[[self alloc] init] autorelease];
}


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
    
    if (!_last) {
        NSAssert(!_head, @"");
        self.head = node;
        self.last = node;

        [self signal];
    } else {
        NSAssert(_head, @"");
        _last.next = node;
        self.last = node;
    }
    
    [self unlock];
}


- (id)poll {
    id result = nil;
    
    [[self retain] autorelease];
    [self lock];
    
    if (_head) {
        NSAssert(_last, @"");
        NSAssert(_head.object, @"");
        result = [[_head.object retain] autorelease];
        self.head = [[[_head retain] autorelease] next];
    }

    [self unlock];
    
    return result;
}


- (id)take {
    id result = nil;
    
    [[self retain] autorelease];
    [self lock];
    
    while (![self available]) {
        [self wait];
    }
    
    NSAssert(_last, @"");
    NSAssert(_head, @"");
    NSAssert(_head.object, @"");
    result = [[_head.object retain] autorelease];
    self.head = [[[_head retain] autorelease] next];
    if (!_head) {
        self.last = nil;
    }
    
    [self unlock];
    
    return result;
}


- (id)takeBeforeDate:(NSDate *)date {
    NSAssert(0, @"TODO");
    return nil;
}


#pragma mark -
#pragma mark Private Business

- (BOOL)available {
    NSAssert((_head && _last) || (!_head && !_last), @"");
    return nil != _last;
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

