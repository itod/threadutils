//
//  TDWorker.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDRunnable;
@protocol TDChannel;

@interface TDWorker : NSObject

+ (TDWorker *)workerWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc;
- (instancetype)initWithRunnable:(id <TDRunnable>)runnable inputChannel:(id <TDChannel>)ic outputChannel:(id <TDChannel>)oc;

@end
