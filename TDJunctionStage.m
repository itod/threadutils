//
//  TDJunctionStage.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 8/17/26.
//  Copyright © 2026 Todd Ditchendorf. All rights reserved.
//

#import "TDJunctionStage.h"
#import "TDJunctionRunner.h"

@implementation TDJunctionStage

- (Class)runnerClass {
    return [TDJunctionRunner class];
}

@end
