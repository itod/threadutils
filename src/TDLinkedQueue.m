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

@property (nonatomic, retain) NSObject *putLock;
@property (nonatomic, retain) NSObject *pollLock;
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
        
        self.putLock = [[[NSObject alloc] init] autorelease];
        self.pollLock = [[[NSObject alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.head = nil;
    self.last = nil;
    
    self.putLock = nil;
    self.pollLock = nil;
    [super dealloc];
}


// -description is not thread safe!
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

    NSAssert(_putLock, @"");
    @synchronized(_putLock) {
        NSAssert(_last, @"");
        @synchronized(_last) { // _last & _head can sometimes be the same node. so, we must lock _last too. Cannot result in deadlock with -poll due to resource ordering
            _last.next = node;
            self.last = node;
        }
    }
}


- (id)poll {
    id result = nil;
    
    NSAssert(_pollLock, @"");
    @synchronized(_pollLock) {
        NSAssert(_head, @"");
        @synchronized(_head) {
            // get the "real" first node. (_head is always a dummy node – an optimization so we can have separate put/poll locks)
            LQNode *first = [[_head.next retain] autorelease];
            if (first) {
                result = [[first.object retain] autorelease];
                first.object = nil; // forget old object
                self.head = first; // become new head
            }
        }
    }
    
    return result;
}

@end
