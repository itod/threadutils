//
//  TDBottleneckStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 3/8/26.
//

#import "TDBottleneckStage.h"
#import <TDThreadUtils/TDWorker.h>

@interface TDBottleneck : TDWorker

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


- (NSUInteger)workerCount {
    return 1;
}


- (Class)workerClass {
    return [TDBottleneck class];
}

@end
