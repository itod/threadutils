Some Cocoa Thread Utilities
===========

##Semaphore

Semaphores allow you to vend a desired number of permits accross multiple threads in a thread-safe manner. 

For example, you may have a pool of a limited number of resources you'd like to vend accross multiple threads. A semaphore can help you do this.

####Create

Create a semaphore with 7 available permits:

    TDSemaphore *sem = [TDSemaphore semaphoreWithValue:7];

####Acquire

There are three different ways to acquire a permit on the current thread. Use one of the following according to your needs:

1. Blocks current thread (possibly forever) until one of the semaphore's permits is acquired:

        [sem acquire];

1. Tries to acquire one of semaphore's permits without blocking the current thread. Always returns immediately with a success indicator:

        BOOL success = [sem attempt];

1. Tries to acquire one of semaphore's permits for up to 10 seconds while blocking the current thread. Always returns within roughly 10 seconds with a success indicator:

        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:10.0];
        
        BOOL success = [sem attemptBeforeDate:date];

Note that all of the above acquisition methods use signal broadcasting techniques (specifically, `NSConditionLock`). **NONE** involve any polling or busy waiting. 

####Relinquish

To relinquish a semaphore's permit owned by the current thread:

    [sem relinquish]; // always returns immediately

##Bounded Buffer

Bounded buffers allow you to pass a given number of buffered objects across one or more threads in FIFO order. Additionally, bounded buffers ensure that a "giver" thread will block when attempting to "give" to the buffer while full, and a "taker" thread will block while attempting to "take" from the buffer while empty.

####Create

Create a bounded buffer with the desired buffer size:

    TDBoundedBuffer *buff = [TDBoundedBuffer boundedBufferWithSize:4];

####Give

The "giver" thread should call `-put:`, which will either:

* return immediately if the buffer currently contains 3 or fewer items.

OR

* if the buffer contains 4 items, the current "giver" thread will block until an item is extracted by another thread.

Example:

    // on "giver" thread
    
    id obj = // …find an object to be given
    
    [buff put:obj]; // blocks while buffer is full, otherwise returns immediately.

####Take
The "taker" thread should call `-take`, which will either:

* extract and return an item immediately if the buffer currently contains 1 or more items.

OR

* if the buffer is empty, the current "taker" thread will block until an item is inserted by another thread.

Example:

    // on "taker" thread
    
    id obj = [buff take]; // blocks while buffer is empty, otherwise returns an item immediately

Note that the  `-put:` and `-take` methods use signal broadcasting techniques (specifically, `NSConditionLock`). They **DO NOT** involve any polling or busy waiting. 

##Synchronous Channel

A synchronous channel is like a bounded buffer with a capacity of `0`. Synchronous channels allow two threads to rendezvous while one thread passes an object to the other. If the "giver" thread arrives at the rendezvous point first, the giver thread will block until the "taker" thread arrives, and has taken the object being given. Alternatively, if the "taker" thread arrives at the rendezvous first, it blocks until the "giver" thread has arrived and given an object to be taken.

So if you have a thread which cannot continue execution until it is guaranteed to have successfully passed an object to another thread, a synchronous channel can help.

####Create

Create a synchronous channel:

    TDSynchronousChannel *chan = [TDSynchronousChannel synchronousChannel];

####Give

The "giver" thread should call `-put:`, which will block until another thread has successfully taken the object:

    // on "giver" thread
    
    id obj = // …find an object to be given
    
    [chan put:obj]; // blocks until `obj` taken by another thread

####Take
The "taker" thread should call `-take`, which will block until another thread has given an object to be taken:

    // on "taker" thread
    
    id obj = [chan take]; // blocks until another thread "gives"    

Note that the order in which these two threads "arrive" at the rendezvous (that is, the order they call `-put:` or `-take`) does not matter. Indeed, across threads it can be difficult to define execution "order" at all. Neither thread will continue beyond the rendezvous point until the object has been successfully taken.

Note that the  `-put:` and `-take` methods use signal broadcasting techniques (specifically, `NSConditionLock`). They **DO NOT** involve any polling or busy waiting. 
