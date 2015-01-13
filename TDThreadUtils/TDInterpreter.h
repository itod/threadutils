//
//  TDInterpreter.h
//  Thread Utils
//
//
//  Created by Todd Ditchendorf on 5/19/14.
//
//

#import <Foundation/Foundation.h>

@interface TDInterpreter : NSObject

+ (instancetype)interpreter;

- (id)awaitPause;
- (void)pauseWithInfo:(id)info;

- (id)awaitResume;
- (void)resumeWithInfo:(id)info;
@end
