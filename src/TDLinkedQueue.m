//
//  TDLinkedQueue.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 10/21/17.
//  Copyright © 2017 Todd Ditchendorf. All rights reserved.
//

#import "TDLinkedQueue.h"

@interface TDLinkedQueue ()
@property (retain) id head;
@end

@implementation TDLinkedQueue

+ (instancetype)queue {
    return [[[self alloc] init] autorelease];
}


- (void)dealloc {
    self.head = nil;
    [super dealloc];
}


- (void)put:(id)obj {
    
}


- (id)poll {
    id obj = nil;
    
    return obj;
}

@end
