//
//  TDWorker.h
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDRunnable;

@protocol TDRunnableDelegate <NSObject>
- (void)runnable:(id <TDRunnable>)r updateProgress:(double)d;
- (void)runnable:(id <TDRunnable>)r updateTitleText:(NSString *)title infoText:(NSString *)info;
@end

@protocol TDRunnable <NSObject>

- (id)runWithInput:(id)input error:(NSError **)outErr;

@property (nonatomic, assign) id <TDRunnableDelegate>delegate;

@end
