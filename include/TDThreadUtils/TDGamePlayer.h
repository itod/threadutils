//
//  TDGamePlayer.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 04.07.18.
//  Copyright © 2018 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDGamePlayer;

@protocol TDGamePlayerDelegate <NSObject>
- (id)gamePlayer:(TDGamePlayer *)p doTurnWithInput:(id)plist;
@end

@interface TDGamePlayer : NSObject

- (instancetype)initWithDelegate:(id <TDGamePlayerDelegate>)d;

- (void)run; // call on a bg thread
- (void)stop; // call on main thread

- (void)giveFirstTurnWithInput:(id)plist; // call on main thread before -run

@property (assign, readonly) id <TDGamePlayerDelegate>delegate;
@property (assign) TDGamePlayer *opponent;
@end
