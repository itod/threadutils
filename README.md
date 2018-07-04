Some Cocoa Concurrency Utilities
===========

* [Semaphore](https://github.com/itod/threadutils#semaphore)
* [Linked Queue](https://github.com/itod/threadutils#linked-queue)
* [Bounded Buffer](https://github.com/itod/threadutils#bounded-buffer)
* [Synchronous Channel](https://github.com/itod/threadutils#synchronous-channel)
* [Exchanger](https://github.com/itod/threadutils#exchanger)
* [Pool](https://github.com/itod/threadutils#pool)
* [Threshold](https://github.com/itod/threadutils#threshold)
* [Trigger](https://github.com/itod/threadutils#trigger)
* [Game](https://github.com/itod/threadutils#game)

----

## Semaphore

Semaphores allow you to vend a desired number of permits accross multiple threads in a thread-safe manner. 

For example, you may have a pool of a limited number of resources you'd like to vend accross multiple threads. A semaphore can help you do this.

#### Create

Create a semaphore with 7 available permits:

```objc
TDSemaphore *sem = [TDSemaphore semaphoreWithValue:7];
```

#### Acquire

There are three different ways to acquire a permit on the current thread. Use one of the following according to your needs:

1. Blocks current thread (possibly forever) until one of the semaphore's permits is acquired:

    ```objc
    [sem acquire];
    ```
1. Tries to acquire one of semaphore's permits without blocking the current thread. Always returns immediately with a success indicator:

    ```objc
    BOOL success = [sem attempt];
    ```
1. Tries to acquire one of semaphore's permits for up to 10 seconds while blocking the current thread. Always returns within roughly 10 seconds with a success indicator:

    ```objc
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:10.0];

    BOOL success = [sem attemptBeforeDate:date];
    ```

Note that all of the above acquisition methods use signal broadcasting techniques (specifically, `NSConditionLock`). **NONE** involve any polling or busy waiting. 

#### Relinquish

To relinquish a semaphore's permit owned by the current thread:

```objc
[sem relinquish]; // always returns immediately
```

---

## Linked Queue

Linked Queues allow you to pass an unbounded number of buffered objects across one or more threads in FIFO order. Additionally, linked queues ensure that a *giver* thread will return quickly when *putting* an object in the queue (enqueueing), and you can choose whether or not you'd like a a *taker* thread to block while attempting to *take* from the queue (dequeueing).

#### Create

Since Linked Queues are unbounded, no size decision must be made at creation time, so creation is simple:

```objc
TDLinkedQueue *q = [TDLinkedQueue linkedQueue];
```

#### Give

The *giver* thread should call `-put:`, which will insert (enqueue) the given item and return quickly.

```objc
id obj = // …find an object to be given

[q put:obj]; // always returns quickly without lengthy blocking
```

#### Take

There are three different ways to take (dequeue) an object on the current thread. Objects are always returned in FIFO order. Use one of the following according to your needs:

1. `-take` blocks the current thread (possibly forever) until another thread has inserted an object in the queue. The result is never `nil`:

    ```objc
    id obj = [q take]; // obj is never nil
    ```
1. `-poll` tries to take an object from the queue without blocking the current thread. Always returns immediately, but the result will be `nil` if the queue is empty:

    ```objc
    id obj = [q poll]; // obj may be nil
    ```
1. `-takeBeforeDate:` tries to take an object from the queue for a given duration while blocking the current thread. Always returns within roughly the duration given, but the result will be `nil` if no object is available for dequeueing during that time:

    ```objc
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:10.0];

    id obj = [q takeBeforeDate:date]; // obj may be nil
    ```
    
Note that the  `-put:` and `-take` methods use signal broadcasting techniques (specifically, `NSConditionLock`). They **DO NOT** involve any polling or busy waiting.

---

## Bounded Buffer

Bounded buffers allow you to pass a given number of buffered objects across one or more threads in FIFO order. Additionally, bounded buffers ensure that a *giver* thread will block when attempting to *give* to the buffer while full, and a *taker* thread will block while attempting to *take* from the buffer while empty.

#### Create

Create a bounded buffer with the desired buffer size:

```objc
TDBoundedBuffer *buff = [TDBoundedBuffer boundedBufferWithSize:4];
```

#### Give

The *giver* thread should call `-put:`, which will either:

* insert the given item and return immediately if the buffer currently contains 3 or fewer items.

OR

* if the buffer contains 4 items, the current *giver* thread will block until an item is extracted by another thread.

```objc
// on "giver" thread

id obj = // …find an object to be given

[buff put:obj]; // blocks while buffer is full, otherwise returns immediately after "putting".
```

#### Take

The *taker* thread should call `-take`, which will either:

* extract and return an item immediately if the buffer currently contains 1 or more items.

OR

* if the buffer is empty, the current *taker* thread will block until an item is inserted by another thread.

```objc
// on "taker" thread

id obj = [buff take]; // blocks while buffer is empty, otherwise returns an item immediately
```

Note that the  `-put:` and `-take` methods use signal broadcasting techniques (specifically, `NSConditionLock`). They **DO NOT** involve any polling or busy waiting. 

---

## Synchronous Channel

A synchronous channel is like a bounded buffer with a capacity of `0`. Synchronous channels allow two threads to rendezvous while one thread passes an object to the other. If the *giver* thread arrives at the rendezvous point first, the giver thread will block until the *taker* thread arrives, and has taken the object being given. Alternatively, if the *taker* thread arrives at the rendezvous first, it blocks until the *giver* thread has arrived and given an object to be taken.

So if you have a thread which cannot continue execution until it is guaranteed to have successfully *passed an object* to another thread, a synchronous channel can help.

#### Create

Create a synchronous channel:

```objc
TDSynchronousChannel *chan = [TDSynchronousChannel synchronousChannel];
```

#### Give

The *giver* thread should call `-put:`, which will block until another thread has successfully taken the object:

```objc
// on "giver" thread

id obj = // …find an object to be given

[chan put:obj]; // blocks until `obj` taken by another thread
```

#### Take

The *taker* thread should call `-take`, which will block until another thread has given an object to be taken:

```objc
// on "taker" thread

id obj = [chan take]; // blocks until another thread "gives"    
```

Note that the order in which these two threads "arrive" at the rendezvous (that is, the order they call `-put:` or `-take`) does not matter. Indeed, across threads it can be difficult to define execution "order" at all. Neither thread will continue beyond the rendezvous point until the object has been successfully taken.

Note that the  `-put:` and `-take` methods use signal broadcasting techniques (specifically, `NSConditionLock`). They **DO NOT** involve any polling or busy waiting. 

---

## Exchanger

An exchanger is a lot like a synchronous channel, except that instead of passing a single object from one thread to another (like relay racers passing a baton), an exchanger allows two threads to rendezvous and swap two objects (like a hostage taker swapping a hostage for ransom).

One thread arrives at the rendezvous point first, gives its "offer" object, and blocks until a second thread arrives to give its own "offer". The objects are swapped, each thread receives its "reward" object and continues execution.

So if you have two threads which cannot continue execution until they are guaranteed to have successfully *swapped objects*, an exchanger can help.

#### Create

Create an exchanger:

```objc
TDExchanger *ex = [TDExchanger exchanger];
```

#### Swap

Each thread should call `-exchange:`, which will block until another thread has also arrived and successfully swapped the given objects:

```objc
// the code is the same on both threads

id offer = // …find an object to be swapped

id reward = [ex exchange:offer]; // blocks until `offer` taken by another thread
```

Note that the  `-exchange:` method uses signal broadcasting techniques (specifically, `NSConditionLock`). It **DOES NOT** involve any polling or busy waiting. 

---

## Pool

A pool maintains a limited collection of resource items that clients can check out and later check back in. Pools rely on a private semaphore for their counting, but provide a higher-level API for vending a limited number of resource objects across multiple threads in a thread-safe manner.

This pool implementation ensures one additional integrity constraint: only objects checked out a from a given pool may be checked back into that same pool.

#### Create

Create a pool by providing it an array of resource items to maintain:

```objc
NSUInteger numItems = … // size of pool
id items = [NSMutableArray arrayWithCapacity:numItems];

for (NSUInteger i = 0; i < numItems; ++i)
    [items addObject:[MyResource new]];

TDPool *pool = [TDPool poolWithItems:items];
```

#### Check Out

Any thread may attempt to *check out* an object from the pool by calling `-takeItem:`. This method will block the current thread until a resource item is available:

```objc
id item = [pool takeItem]; // blocks until item is available

… // use item
```

#### Check In

Any item checked out of a pool should later be *checked back in* by passing it to `-returnItem:`. This method will always return immediately. The item need not be checked back in on the same thread.

```objc
… // finish using item

[pool returnItem:item]; // returns immediately
```

If any other threads were blocked while waiting to check out a resource item, one of those threads will be unblocked and returned this item.

#### Safety

For the sake of safety, it may be best to wrap the item usage and check in inside of a try/finally block:

```objc
id item = [pool takeItem];
@try { use(item); }
@finally { [pool returnItem:item]; }
```

---

## Threshold

A threshold is a way to block multiple threads until a threshold is met.

A threshold object will block any thread that calls its `-await` method until a given number of threads have have done so. At that point, the threshold is met, and all waiting threads will be unblocked and allowed to continue simultaneously.

A threshold is useful for designs which call for a specific number of independent actors or tasks (represented as threads) with no centralized mediator or controller. Using a threshold, these threads can be created and blocked until the exact moment when the desired number have been initialized and are waiting. Then, they all continue simultaneously.

#### Create

Usage is simple. Create a threshold with the desired limit:

```objc
TDThreshold *th = [TDThreshold thresholdWithValue:4];
```

#### Await

On any thread which should block until the threshold limit is reached, call `-await`.

```objc
[th await]; // blocks until threshold limit is reached
```

In this example, when `-await` is called for the fourth time (on the fourth thread), the three waiting threads, and the current fourth thread will all unblock and continue execution "simultaneously" (note the precise meaning of "simultaneously" is dependent on the number of cores on your device's processor and the thread scheduling behavior of your operating system).

Note that the  `-await` method uses signal broadcasting techniques (specifically, `NSConditionLock`). It **DOES NOT** involve any polling or busy waiting. 

---

## Trigger

A trigger is a way to block multiple threads until a *fire* signal is explicitly sent by a controller thread.

Triggers are very similar to thresholds, but are approriate for designs that call for a controller or mediator to unblock all waiting threads in response to a specific condition explicitly coded by the programmer.

#### Create

```objc
TDTrigger *trig = [TDTrigger trigger];
```

#### Await

On any thread you wish to block, call `-await`:

```objc
[trig await]; // blocks until "fire" signal sent by controller
```

This will block the current thread until the *fire* signal is sent by some other controlling thread.

#### Fire

When your application is ready for all waiting threads to proceed with execution, *fire* the trigger on an unblocked controlling thread:

```objc
[trig fire]; // unblocks all threads waiting on this trigger
```

All threads that were waiting on this trigger will unblock and proceed simultaneously.

Note that the  `-await` and `-fire` methods use signal broadcasting techniques (specifically, `NSConditionLock`). They **DO NOT** involve any polling or busy waiting. 

---

## Game

A game is a way to allow exactly two threads to take turns running exclusively with respect to one another.

While thread A takes its "turn", thread B is awaiting its "turn" in a paused state. After thread A completes its "move", it pauses while thread B takes its "turn". Then, after thread B has executed its own "move", it pauses and gives thread A another "turn". This exclusive turn-taking continues indefinitely until the user stops the game.

Games are useful for implementing anything like a language interpreter with an interactive debugger. When such an interpreter is running, one of two threads (the code execution thread or the user debug command input thread) must be taking its turn running while the other thread is paused awaiting its turn.

#### Create

To set up a game, create exactly two players, and set them as each other's opponent. Also, provide each player with a delegate which executes your "move" logic by adopting the `TDGamePlayerDelegate` protocol and implementing the `-executeMoveForPlayer:` method.

```objc
id <TDGamePlayerDelegate>del1 = … // implements "move" logic for player #1
id <TDGamePlayerDelegate>del2 = … // implements "move" logic for player #2

id p1 = [[TDGamePlayer alloc] initWithDelegate:del1];
id p2 = [[TDGamePlayer alloc] initWithDelegate:del2];

p1.opponent = p2;
p2.opponent = p1;
```

#### Run

To begin the game, allow exactly one player to take its turn, and run each player on a separate background thread of your choosing. Each of your two player delegates will receive repeated calls to execute their "moves" on their own thread while the other player's thread is paused.

```objc
[p1 giveTurn];

performOnNewBackgroundThread(^{
    [p1 run];
});
performOnNewBackgroundThread(^{
    [p2 run];
});
```

#### Stop

Stopping a game is easy. Call each player's `-stop` method from any thread.

```objc
[p1 stop];
[p2 stop];
```

