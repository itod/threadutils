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
@property (retain) id input;
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
    self.input = nil;
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
                [self doTurn];
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


- (void)giveFirstTurnWithInput:(id)plist {
    [self lock];
    
    self.input = plist;
    
    [self unlock];
    
    [self giveTurn]; // open call
}


#pragma mark -
#pragma mark Private

- (void)giveTurn {
    [self lock];
    
    self.myTurn = YES;
    [self signal];
    
    [self unlock];
}


- (void)releaseTurn {
    TDGamePlayer *p = nil;
    
    [self lock];
    
    self.myTurn = NO;
    p = self.opponent;
    
    [self unlock];
    
    [p giveTurn]; // open call
}


- (void)awaitTurn {
    [self lock];
    
    while (!self.myTurn) {
        [self wait];
    }
    
    [self unlock];
}


- (void)doTurn {
    NSAssert(self.delegate, @"");
    
    id input = self.input;
    
    // TODO round-trip serialize input plist here
    
    id output = [self.delegate gamePlayer:self doTurnWithInput:input];
    self.opponent.input = output;
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
