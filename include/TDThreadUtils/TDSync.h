//
//  TDSync.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDSync <NSObject>
- (void)acquire;
- (void)relinquish;
@end
