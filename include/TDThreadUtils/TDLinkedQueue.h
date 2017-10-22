//
//  TDLinkedQueue.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 10/21/17.
//  Copyright © 2017 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDChannel.h>

@interface TDLinkedQueue : NSObject <TDChannel>

- (void)put:(id)obj; // returns immediately without blocking. capacity is unbounded

- (id)poll; // returns immediately without blocking. may be nil
- (id)take; // blocks indefinitely while waiting for object to become available.
- (id)takeBeforeDate:(NSDate *)date; // blocks until date while waiting for object to become available.

@end
