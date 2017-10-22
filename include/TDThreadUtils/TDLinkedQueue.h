//
//  TDLinkedQueue.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 10/21/17.
//  Copyright © 2017 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDLinkedQueue : NSObject

- (void)put:(id)obj; // returns immediately without blocking. capacity is unbounded.

- (id)poll; // returns immediately without blocking. may be nil
- (id)take; // blocks while waiting for object to become available.
- (id)takeBeforeDate:(NSDate *)date;

@end
