//
//  TDBottleneckStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 3/8/26.
//

#import "TDBottleneckStage.h"
#import <TDThreadUtils/TDRunnable.h>

@interface TDBottleneck : TDRunnable

@end

@implementation TDBottleneck

- (id)runWithInput:(id)input error:(NSError **)outErr {
    return input;
}

@end

@implementation TDBottleneckStage

- (BOOL)isBottleneck {
    return YES;
}


- (NSUInteger)runnerCount {
    return 1;
}


- (Class)runnableClass {
    return [TDBottleneck class];
}

@end
