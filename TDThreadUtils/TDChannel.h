//
//  TDChannel.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDChannel <NSObject>
- (void)put:(id)obj;
- (id)take;
@end
