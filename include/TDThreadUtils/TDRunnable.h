//
//  TDRunnable.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TDRunnable;

@protocol TDRunnableDelegate <NSObject>
- (void)runnable:(TDRunnable *)r updateProgress:(double)d;
- (void)runnable:(TDRunnable *)r updateTitleText:(NSString *)title infoText:(NSString *)info;
- (void)runnable:(TDRunnable *)r sendToSink:(id)data;
@end

@interface TDRunnable : NSObject

// designated initializer
- (instancetype)initWithDelegate:(id <TDRunnableDelegate>)d;

// main pipeline channel
- (id)runWithInput:(id)input error:(NSError **)outErr;

// parallel sink channel. return YES for success
+ (BOOL)sinkData:(id)data error:(NSError **)outErr;
+ (BOOL)wantsSink;

@property (nonatomic, assign, readonly) id <TDRunnableDelegate>delegate;

@end
