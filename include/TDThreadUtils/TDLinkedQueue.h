//
//  TDLinkedQueue.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 10/21/17.
//  Copyright © 2017 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDLinkedQueue : NSObject

+ (instancetype)queue;

- (void)put:(id)obj;
- (id)poll;

@end
