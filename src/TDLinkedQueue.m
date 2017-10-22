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
    [super dealloc];
}

@end

@interface TDLinkedQueue ()
@property (retain) LQNode *head;
@property (retain) LQNode *last;
@end

@implementation TDLinkedQueue

+ (instancetype)queue {
    return [[[self alloc] init] autorelease];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.head = [[[LQNode alloc] init] autorelease];
        self.last = _head;
    }
    return self;
}


- (void)dealloc {
    self.head = nil;
    self.last = nil;
    [super dealloc];
}


- (NSString *)description {
    NSMutableString *buf = [NSMutableString string];
    
    NSAssert(_head, @"");
    LQNode *node = _head.next;
    
    while (node) {
        [buf appendFormat:@"%@%@", node.object, node.next ? @"->" : @""];
        node = node.next;
    }
    
    return [NSString stringWithFormat:@"<%@ %p %@>", [self class], self, buf];
}


- (void)put:(id)obj {
    NSParameterAssert(obj);
    
    LQNode *node = [[[LQNode alloc] initWithObject:obj] autorelease];
    
    NSAssert(_last, @"");
    _last.next = node;
    self.last = node;
}


- (id)poll {
    id obj = nil;
    
    NSAssert(_head.next, @"");
    LQNode *node = [[_head.next retain] autorelease];
    _head.next = node.next;
    
    obj = [[node.object retain] autorelease];
    node.object = nil;
    
    return obj;
}

@end
