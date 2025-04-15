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

@interface TDRunner : NSObject <TDRunnableDelegate>

+ (TDRunner *)runnerWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i;
- (instancetype)initWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i;

- (void)run;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *labelText;
@end
