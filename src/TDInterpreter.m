//
//  TDInterpreter.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <TDThreadUtils/TDInterpreter.h>
#import <TDThreadUtils/TDSynchronousChannel.h>

@interface TDInterpreter ()
@property (retain) TDSynchronousChannel *channel;
@end

@implementation TDInterpreter

+ (instancetype)interpreter {
    return [[[self alloc] init] autorelease];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.channel = [TDSynchronousChannel synchronousChannel];
    }
    return self;
}


- (void)dealloc {
    self.channel = nil;
    [super dealloc];
}


- (id)awaitPause {
    NSAssert(_channel, @"");
    return [_channel take];
}


- (void)pauseWithInfo:(id)info {
    NSAssert(_channel, @"");
    [_channel put:info];
}


- (id)awaitResume {
    NSAssert(_channel, @"");
    return [_channel take];
}


- (void)resumeWithInfo:(id)info {
    NSAssert(_channel, @"");
    [_channel put:info];
}

@end
