//
//  TDBoundedBuffer.m
//  TDThreadUtils
//
//  Created by Todd Ditchendorf on 1/12/15.
//  Copyright (c) 2015 Todd Ditchendorf. All rights reserved.
//

#import <TDThreadUtils/TDBoundedBuffer.h>
#import <TDThreadUtils/TDSemaphore.h>

@interface TDBufferArray : NSObject
- (instancetype)initWithSize:(NSUInteger)size;
- (void)insert:(id)obj;
- (id)extract;

@property (retain) NSMutableArray *array;
@property (assign) NSUInteger size;
@property (assign) NSUInteger putIndex;
@property (assign) NSUInteger takeIndex;
@end

@implementation TDBufferArray

- (instancetype)initWithSize:(NSUInteger)size {
    NSParameterAssert(NSNotFound != size);
    NSParameterAssert(size > 0);
    self = [super init];
    if (self) {
        self.size = size;
        self.array = [NSMutableArray arrayWithCapacity:size];
    }
    return self;
}


- (void)dealloc {
    self.array = nil;
    [super dealloc];
}


- (void)insert:(id)obj {
    NSParameterAssert(obj);
    NSAssert(_array, @"");
    
    @synchronized(self) {
        _array[_putIndex] = obj;
        self.putIndex = (_putIndex + 1) % _size;
    }
    
    NSAssert([_array count] <= _size, @"");
    NSAssert(_putIndex < _size, @"");
}


- (id)extract {
    NSAssert(_array, @"");
    
    id obj = nil;
    @synchronized(self) {
        obj = [[_array[_takeIndex] retain] autorelease];
        [_array removeObjectAtIndex:_takeIndex];
        self.takeIndex = (_takeIndex + 1) % _size;
    }

    NSAssert([_array count] <= _size, @"");
    NSAssert(_takeIndex < _size, @"");
    return obj;
}

@end


@interface TDBoundedBuffer ()
@property (retain) TDBufferArray *buffer;
@property (retain) TDSemaphore *putPermits;
@property (retain) TDSemaphore *takePermits;
@end

@implementation TDBoundedBuffer

+ (instancetype)boundedBufferWithSize:(NSUInteger)size {
    return [[(TDBoundedBuffer *)[self alloc] initWithSize:size] autorelease];
}


- (instancetype)initWithSize:(NSUInteger)size {
    NSParameterAssert(NSNotFound != size);
    NSParameterAssert(size > 0);
    self = [super init];
    if (self) {
        self.buffer = [[[TDBufferArray alloc] initWithSize:size] autorelease];
        self.putPermits = [TDSemaphore semaphoreWithValue:size];
        self.takePermits = [TDSemaphore semaphoreWithValue:0];
    }
    return self;
}


- (void)dealloc {
    self.buffer = nil;
    self.putPermits = nil;
    self.takePermits = nil;
    [super dealloc];
}


- (void)put:(id)obj {
    NSParameterAssert(obj);
    NSAssert(_buffer, @"");
    NSAssert(_putPermits, @"");
    NSAssert(_takePermits, @"");
    
    [_putPermits acquire];
    [_buffer insert:obj];
    [_takePermits relinquish];
}


- (id)take {
    NSAssert(_buffer, @"");
    NSAssert(_putPermits, @"");
    NSAssert(_takePermits, @"");
    
    [_takePermits acquire];
    id obj = [_buffer extract];
    [_putPermits relinquish];
    
    NSAssert(obj, @"");
    return obj;
}


- (void)put:(id)obj beforeDate:(NSDate *)date {
    NSParameterAssert(obj);
    NSAssert(_buffer, @"");
    NSAssert(_putPermits, @"");
    NSAssert(_takePermits, @"");
    
    [_putPermits attemptBeforeDate:date];
    [_buffer insert:obj];
    [_takePermits relinquish];
}


- (id)takeBeforeDate:(NSDate *)date {
    NSAssert(_buffer, @"");
    NSAssert(_putPermits, @"");
    NSAssert(_takePermits, @"");

    [_takePermits attemptBeforeDate:date];
    id obj = [_buffer extract];
    [_putPermits relinquish];
    
    NSAssert(obj, @"");
    return obj;
}

@end
