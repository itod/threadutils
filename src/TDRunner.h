//
//  TDRunner.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TDThreadUtils/TDRunnable.h>

@protocol TDChannel;

@interface TDRunner : NSObject <TDRunnableDelegate>

+ (TDRunner *)runnerWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i;
- (instancetype)initWithInputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc number:(NSUInteger)i;

- (void)run;

@property (nonatomic, retain) TDRunnable *runnable;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) NSString *titleText;
@property (nonatomic, copy) NSString *infoText;

@end
