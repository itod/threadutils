//
//  TDPool.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 5/21/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDPool.h>
#import <TDThreadUtils/TDSemaphore.h>

@interface TDPool ()
@property (nonatomic, retain) TDSemaphore *available;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableSet *busy; // busy property is used only to ensure that returned objs were in fact previously taken from this pool.
@end

@implementation TDPool

+ (instancetype)poolWithSize:(NSUInteger)size {
    return [[(TDPool *)[self alloc] initWithSize:size] autorelease];
}


- (instancetype)initWithSize:(NSUInteger)size {
    NSParameterAssert(NSNotFound != size);
    NSParameterAssert(size > 0);
    self = [super init];
    if (self) {
        self.available = [TDSemaphore semaphoreWithValue:size];
        self.items = [NSMutableArray arrayWithCapacity:size];
        self.busy = [NSMutableSet setWithCapacity:size];
    }
    return self;
}


- (void)dealloc {
    self.available = nil;
    self.items = nil;
    self.busy = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (id)takeItem {
    NSAssert(_available, @"");
    [_available acquire];
    
    id obj = [self doTake];
    NSAssert(obj, @"");
    return obj;
}


- (void)returnItem:(id)obj {
    NSParameterAssert(obj);
    
    if ([self doReturn:obj]) {
        NSAssert(_available, @"");
        [_available relinquish];
    }
}


- (void)initializeItems:(NSUInteger)size {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
}


#pragma mark -
#pragma mark Private

- (id)doTake {
    id obj = nil;
    
    @synchronized(self) {
        NSAssert([_items count], @"");
        obj = [[[_items lastObject] retain] autorelease];
        [_items removeLastObject];
        
        NSAssert(_busy, @"");
        NSAssert(![_busy containsObject:obj], @"");
        [_busy addObject:obj];
    }
    
    return obj;
}


- (BOOL)doReturn:(id)obj {
    BOOL result = YES;
    
    @synchronized(self) {
        NSAssert(_busy, @"");
        if ([_busy containsObject:obj]) {
            NSAssert(_items, @"");
            [_items addObject:obj];
        } else {
            result = NO;
            NSAssert(0, @"");
        }
    }
    
    return result;
}

@end
