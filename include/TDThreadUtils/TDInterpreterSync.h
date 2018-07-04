//
//  TDInterpreterSync.h
//  TDThreadUtils
//
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <Foundation/Foundation.h>

@interface TDInterpreterSync : NSObject

+ (instancetype)interpreterSync;

// called from interp execution thread
- (void)pauseWithInfo:(id)info;
- (id)awaitResume;

// called from user command/control thread
- (void)resumeWithInfo:(id)info;
- (id)awaitPause;

@end
