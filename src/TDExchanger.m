//
//  TDExchanger.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <TDThreadUtils/TDExchanger.h>
#import <TDThreadUtils/TDSynchronousChannel.h>

@interface TDExchanger ()
@property (retain) TDSynchronousChannel *channelA;
@property (retain) TDSynchronousChannel *channelB;
@property (assign) BOOL flag;
@end

@implementation TDExchanger

+ (instancetype)exchanger {
    return [[[self alloc] init] autorelease];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.channelA = [TDSynchronousChannel synchronousChannel];
        self.channelB = [TDSynchronousChannel synchronousChannel];
    }
    return self;
}


- (void)dealloc {
    self.channelA = nil;
    self.channelB = nil;
    [super dealloc];
}


- (id)exchange:(id)inObj {
    NSParameterAssert(inObj);
    NSAssert(_channelA, @"");
    NSAssert(_channelB, @"");
    
    BOOL flag;
    @synchronized (self) {
        flag = self.flag;
        self.flag = !self.flag;
    }
    
    id outObj = nil;
    if (flag) {
        [_channelA put:inObj];
        outObj = [_channelB take];
    } else {
        outObj = [_channelA take];
        [_channelB put:inObj];
    }
    
    NSAssert(outObj, @"");
    return outObj;
}

@end
