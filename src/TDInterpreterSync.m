//
//  TDInterpreterSync.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <TDThreadUtils/TDInterpreterSync.h>
#import <TDThreadUtils/TDBoundedBuffer.h>

@interface TDInterpreterSync ()
@property (retain) TDBoundedBuffer *pauseChannel;
@property (retain) TDBoundedBuffer *resumeChannel;
@end

@implementation TDInterpreterSync

+ (instancetype)interpreterSync {
    return [[[self alloc] init] autorelease];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.pauseChannel = [TDBoundedBuffer boundedBufferWithSize:1];
        self.resumeChannel = [TDBoundedBuffer boundedBufferWithSize:1];
    }
    return self;
}


- (void)dealloc {
    self.pauseChannel = nil;
    self.resumeChannel = nil;
    [super dealloc];
}


- (id)awaitPause {
    NSAssert(_pauseChannel, @"");
    return [_pauseChannel take];
}


- (void)pauseWithInfo:(id)info {
    NSAssert(_pauseChannel, @"");
    [_pauseChannel put:info];
}


- (id)awaitResume {
    NSAssert(_resumeChannel, @"");
    return [_resumeChannel take];
}


- (void)resumeWithInfo:(id)info {
    NSAssert(_resumeChannel, @"");
    [_resumeChannel put:info];
}

@end
