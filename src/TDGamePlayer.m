//
//  TDGamePlayer.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 04.07.18.
//  Copyright © 2018 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDGamePlayer.h>

@interface TDGamePlayer ()
@property (assign, readwrite) id <TDGamePlayerDelegate>delegate;
@property (assign) BOOL myTurn;
@property (assign) BOOL stopped;
@property (retain) NSCondition *monitor;
@end

@implementation TDGamePlayer

- (instancetype)init {
    self = [self initWithDelegate:nil];
    return self;
}


- (instancetype)initWithDelegate:(id <TDGamePlayerDelegate>)d {
    NSParameterAssert(d );
    self = [super init];
    if (self) {
        self.delegate = d;
        self.myTurn = NO;
        self.stopped = NO;
        self.monitor = [[[NSCondition alloc] init] autorelease];
    }
    return self;
}


- (void)dealloc {
    self.delegate = nil;
    self.opponent = nil;
    self.monitor = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (void)run {
    NSAssert(![NSThread isMainThread], @"");
    NSAssert(![self done], @"Can only call -run once");
    
    for (;;) {
        [self awaitTurn];
        
        BOOL done = [self done];
        
        @try {
            if (done) {
                break;
            } else {
                [self move];
            }
        }
        @finally {
            [self releaseTurn];
        }
    }
}


- (void)stop {
    [self lock];
    
    self.stopped = YES;
    
    [self unlock];
}


- (BOOL)done {
    BOOL done = NO;
    
    [self lock];
    
    done = self.stopped;
    
    [self unlock];
    
    return done;
}


- (void)takeTurn {
    [self lock];
    
    self.myTurn = YES;
    [self signal];
    
    [self unlock];
}


#pragma mark -
#pragma mark Private

- (void)releaseTurn {
    TDGamePlayer *p = nil;
    
    [self lock];
    
    self.myTurn = NO;
    p = self.opponent;
    
    [self unlock];
    
    [p takeTurn]; // open call
}


- (void)awaitTurn {
    [self lock];
    
    while (!self.myTurn) {
        [self wait];
    }
    
    [self unlock];
}


- (void)move {
    NSAssert(self.delegate, @"");
    [self.delegate executeMoveForGamePlayer:self];
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


- (void)signal {
    NSAssert(_monitor, @"");
    [_monitor signal];
}

@end
