//
//  TDRunnable.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 4/14/25.
//  Copyright © 2025 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDRunnable.h>

@interface TDRunnable ()
@property (nonatomic, assign, readwrite) id <TDRunnableDelegate>delegate;
@end

@implementation TDRunnable

- (instancetype)init {
    NSAssert(0, @"");
    self = [self initWithDelegate:nil];
    return self;
}


- (instancetype)initWithDelegate:(id <TDRunnableDelegate>)d {
    self = [super init];
    if (self) {
        self.delegate = d;
    }
    return self;
}


- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
}


- (id)runWithInput:(id)input error:(NSError **)outErr {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
    return nil;
}


- (void)sinkData:(id)data error:(NSError **)outErr {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
}

@end
