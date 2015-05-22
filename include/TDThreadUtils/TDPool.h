//
//  TDPool.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/21/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSArray *(^TDPoolInitializationBlock)(NSUInteger size);

@interface TDPool : NSObject

+ (instancetype)poolWithSize:(NSUInteger)size initializationBlock:(TDPoolInitializationBlock)block;
- (instancetype)initWithSize:(NSUInteger)size initializationBlock:(TDPoolInitializationBlock)block;

- (id)takeItem;
- (void)returnItem:(id)obj;

@end
