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
- (instancetype)initWithCapacity:(NSUInteger)size;
- (void)insert:(id)obj;
- (id)extract;

@property (assign) NSUInteger capacity;
@property (assign) NSUInteger count;
@property (assign) NSUInteger putIndex;
@property (assign) NSUInteger takeIndex;
@end

@implementation TDBufferArray {
    id *_array;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    NSParameterAssert(NSNotFound != capacity);
    NSParameterAssert(capacity > 0);
    self = [super init];
    if (self) {
        self.capacity = capacity;
        self.count = 0;
        _array = malloc(sizeof(id) * _capacity);
    }
    return self;
}


- (void)dealloc {
    free(_array);
    [super dealloc];
}


- (void)insert:(id)obj {
    NSParameterAssert(obj);
    NSAssert(_array, @"");
    
    [obj retain]; // +1
    
    @synchronized(self) {
        self.count++;
        NSUInteger idx = self.putIndex;
        _array[idx] = obj;
        self.putIndex = (idx + 1) % _capacity;
        NSAssert(self.putIndex < self.capacity, @"");
    }
}


- (id)extract {
    NSAssert(_array, @"");
    
    id obj = nil;
    @synchronized(self) {
        self.count--;
        NSUInteger idx = self.takeIndex;
        obj = _array[idx];
        _array[idx] = nil;
        self.takeIndex = (idx + 1) % _capacity;
        NSAssert(self.takeIndex < self.capacity, @"");
    }

    return [obj autorelease]; // -1
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
        self.buffer = [[[TDBufferArray alloc] initWithCapacity:size] autorelease];
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


- (BOOL)put:(id)obj beforeDate:(NSDate *)date {
    NSParameterAssert(obj);
    NSAssert(_buffer, @"");
    NSAssert(_putPermits, @"");
    NSAssert(_takePermits, @"");
    
    BOOL success = [_putPermits attemptBeforeDate:date];
    if (success) {
        [_buffer insert:obj];
        [_takePermits relinquish];
    }
    return success;
}


- (id)takeBeforeDate:(NSDate *)date {
    NSAssert(_buffer, @"");
    NSAssert(_putPermits, @"");
    NSAssert(_takePermits, @"");

    id obj = nil;
    
    if ([_takePermits attemptBeforeDate:date]) {
        obj = [_buffer extract];
        [_putPermits relinquish];
        NSAssert(obj, @"");
    }
    return obj;
}


- (NSUInteger)count {
    return _buffer.count;
}

@end
