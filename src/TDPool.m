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
@property (nonatomic, retain) TDSemaphore *permits;
@property (nonatomic, retain) NSMutableArray *available;
@property (nonatomic, retain) NSMutableSet *busy; // `busy` collection is used only to ensure that returned objs were in fact previously taken from this pool.
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
        self.permits = [TDSemaphore semaphoreWithValue:size];
        self.available = [NSMutableArray arrayWithCapacity:size];
        self.busy = [NSMutableSet setWithCapacity:size];
    }
    return self;
}


- (void)dealloc {
    self.permits = nil;
    self.available = nil;
    self.busy = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark Public

- (id)takeItem {
    NSAssert(_permits, @"");
    [_permits acquire];
    
    id obj = [self doTake];
    NSAssert(obj, @"");
    return obj;
}


- (void)returnItem:(id)obj {
    NSParameterAssert(obj);
    
    if ([self doReturn:obj]) {
        NSAssert(_permits, @"");
        [_permits relinquish];
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
        NSAssert([_available count], @"");
        obj = [[[_available lastObject] retain] autorelease];
        [_available removeLastObject];
        
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
            NSAssert(_available, @"");
            [_available addObject:obj];
        } else {
            result = NO;
            NSAssert(0, @"");
        }
    }
    
    return result;
}

@end
