//
//  TDSynchronousChannel.m
//  Panthro
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import "TDSynchronousChannel.h"
#import "TDLocking.h"
#import "TDSemaphore.h"

@interface TDSynchronousChannel ()
@property (retain) TDSemaphore *putPermit;
@property (retain) TDSemaphore *takePermit;
@property (retain) id item;
@end

@implementation TDSynchronousChannel

+ (instancetype)synchronousChannel {
    return [[[self alloc] init] autorelease];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.putPermit = [TDSemaphore semaphoreWithValue:1];
        self.takePermit = [TDSemaphore semaphoreWithValue:0];
    }
    return self;
}


- (void)dealloc {
    self.putPermit = nil;
    self.takePermit = nil;
    self.item = nil;
    [super dealloc];
}


- (void)put:(id)obj {
    NSAssert(_putPermit), @"");
    NSAssert(_takePermit), @"");

    [_putPermit acquire];
    NSAssert(!_item), @"");
    self.item = obj;
    [_takePermit relinquish];
}


- (id)take {
    NSAssert(_putPermit), @"");
    NSAssert(_takePermit), @"");
    
    [_takePermit acquire];
    NSAssert(_item), @"");
    id obj = [[_item retain] autorelease];
    self.item = nil;
    [_putPermit relinquish];

    return obj;
}

@end
