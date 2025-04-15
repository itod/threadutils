//
//  TDWorker.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDThreadUtils/TDRunnable.h>

@protocol TDChannel;

@interface Runner : NSObject <TDRunnableDelegate>

+ (Runner *)runnerWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i;
- (instancetype)initWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i;

- (void)run;
@end
