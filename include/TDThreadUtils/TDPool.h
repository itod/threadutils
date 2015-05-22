//
//  TDPool.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/21/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TDPool : NSObject

+ (instancetype)poolWithSize:(NSUInteger)size;
- (instancetype)initWithSize:(NSUInteger)size;

- (id)takeItem;
- (void)returnItem:(id)obj;

- (void)initializeItems:(NSUInteger)size; // subclasses should override to populate pool

@end
