//
//  TDPool.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/21/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPool : NSObject

+ (instancetype)poolWithItems:(NSArray *)items;
- (instancetype)initWithItems:(NSArray *)items;

- (id)takeItem;
- (void)returnItem:(id)obj;

@end
