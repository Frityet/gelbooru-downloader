#include "Future.h"

@interface _FutureObserver : OFObject
@property (nonatomic, nullable) OFRunLoop *runLoop;
@property (nonatomic, nullable) OFRunLoopMode mode;
@property (nonatomic, copy) FutureCompletionHandler_f ^handler;
@end
@implementation _FutureObserver @end

// Helper class to work around OFTimer block double-free bug
// OFTimer with blocks has a bug where _block is released in invalidate() 
// but not set to nil, then released again in dealloc()
@interface _FutureTimerTarget : OFObject {
    void (^_block)(OFTimer *);
}
@property (nonatomic, copy) void (^block)(OFTimer *);
- (void)fire:(OFTimer *)timer;
@end

@implementation _FutureTimerTarget
@synthesize block = _block;

- (instancetype)init {
    self = [super init];
    _block = nil;
    return self;
}

- (void)fire:(OFTimer *)timer
{
    if (_block) _block(timer);
}

@end

@interface Future ()
- (instancetype)of_initWithRunLoop:(OFRunLoop *nillable)runLoop
                              mode:(OFRunLoopMode nillable)mode
                              [[clang::objc_method_family(init)]];
- (void)of_completeWithValue:(id nillable)value exception:(id nillable)exception;
- (void)of_scheduleOnRunLoop:(OFRunLoop *nillable)runLoop
                        mode:(OFRunLoopMode nillable)mode
                       block:(void (^)(OFTimer *))block;
@end

@implementation Future {
    bool _completed;
    id nillable _value;
    id nillable _exception;

    OFRunLoop *nillable _deliveryRunLoop;
    OFRunLoopMode nillable _deliveryRunLoopMode;

    OFMutableArray<_FutureObserver *> *_observers;
}

- (instancetype)of_initWithRunLoop:(OFRunLoop *nillable)runLoop
                              mode:(OFRunLoopMode nillable)mode
{
    self = [super init];
    _deliveryRunLoop = runLoop;
    _deliveryRunLoopMode = mode;
    _observers = [[OFMutableArray alloc] init];
    return self;
}

+ (instancetype)resolved:(id)value
{
    Future *f = [[self alloc] of_initWithRunLoop:[OFRunLoop currentRunLoop] mode:nil];
    [f of_completeWithValue:value exception:nil];
    return f;
}

+ (instancetype)rejected:(id)exception
{
    Future *f = [[self alloc] of_initWithRunLoop:[OFRunLoop currentRunLoop] mode:nil];
    [f of_completeWithValue:nil exception:exception];
    return f;
}

+ (instancetype)pure:(id)x
{
    return [self resolved:x];
}

+ (instancetype)futureWithRunLoop:(nullable OFRunLoop *)runLoop
                             mode:(nullable OFRunLoopMode)mode
                            start:(void (^)(void (^resolve)(id _Nullable),
                                            void (^reject)(OFException *nillable)))start
{
    FuturePromise *p = [FuturePromise promiseWithRunLoop:runLoop mode:mode];
    Future *f = p.future;

    // Capture p strongly in both blocks to prevent deallocation before async completion
    __block FuturePromise *strongP = p;
    void (^resolve)(id _Nullable) = ^(id _Nullable v) { 
        [strongP resolve:v]; 
    };
    void (^reject)(id) = ^(id e) { 
        [strongP reject:e]; 
    };

    @try {
        if (start) start(resolve, reject);
    } @catch (id e) {
        [p reject:e];
    }

    return f;
}

+ (instancetype)futureWithAsyncBlock:(void (^)(void (^resolve)(id nillable value), void (^reject)(OFException *nillable exception)))start
{
    return [self futureWithRunLoop: OFRunLoop.currentRunLoop mode: nil start: start];
}

+ (Future<OFArray<id> *> *)all:(OFArray<Future<id> *> *)futures
{
    if (futures.count == 0)
        return [Future resolved: [OFArray array]];

    OFRunLoop *rl = [OFRunLoop currentRunLoop];
    
    // Keep a strong reference to futures array to prevent deallocation
    __block OFArray<Future<id> *> *retainedFutures = futures;

    return [Future futureWithRunLoop: rl mode: nil start: ^(void (^resolve)(OFArray<id> *nillable), void (^reject)(id)) {

        auto results = [OFMutableArray arrayWithCapacity: retainedFutures.count];
        for (size_t i = 0; i < retainedFutures.count; i++)
            [results addObject: OFNull.null];

        __block size_t remaining = retainedFutures.count;
        __block bool settled = false;

        [retainedFutures enumerateObjectsUsingBlock:^(Future<id> *f, size_t idx, bool *stop) {
            [f whenComplete:^(id value, id exception) {
                // Capture retainedFutures to keep them alive until all complete
                if (retainedFutures == nil) return; // forces capture
                @synchronized(results) {
                    if (settled)
                        return;

                    if (exception != nil) {
                        settled = true;
                        reject(exception);
                        return;
                    }

                    results[idx] = value ?: (id)OFNull.null;

                    if (--remaining == 0) {
                        settled = true;
                        resolve([results copy]);
                    }
                }
            }];
        }];
    }];
}


- (bool)completed { @synchronized(self) { return _completed; } }
- (bool)fulfilled { @synchronized(self) { return (_completed and _exception == nil); } }
- (bool)rejected  { @synchronized(self) { return (_completed and _exception != nil); } }

- (id)value     { @synchronized(self) { return _value; } }
- (id)exception { @synchronized(self) { return _exception; } }

- (OFRunLoop *)deliveryRunLoop { return _deliveryRunLoop; }
- (OFRunLoopMode)deliveryRunLoopMode { return _deliveryRunLoopMode; }

- (Future *)deliverOnRunLoop:(OFRunLoop *nillable)runLoop
                        mode:(OFRunLoopMode nillable)mode
{
    FuturePromise *p = [FuturePromise promiseWithRunLoop:runLoop mode:mode];

// typedef void FutureCompletionHandler_f(nillable T value, OFException *nillable error);
// - (void)whenCompleteOnRunLoop:(OFRunLoop *nillable)runLoop mode:(OFRunLoopMode nillable)mode handler:(FutureCompletionHandler_f)handler;

    [self whenCompleteOnRunLoop:runLoop mode:mode handler: ^(id nillable v, OFException *nillable e) {
        if (e) [p reject: (OFException *)e];
        else   [p resolve:v];
    }];

    return p.future;
}

- (void)of_scheduleOnRunLoop:(OFRunLoop *nillable)runLoop
                        mode:(OFRunLoopMode)mode
                       block:(void (^)(OFTimer *))block
{
    if (not block) return;

    if (not runLoop) {
        block(nilptr);
        return;
    }

    // Use target/selector approach instead of block to avoid ObjFW OFTimer 
    // double-free bug where _block is released in invalidate() but not nil'd,
    // then released again in dealloc()
    _FutureTimerTarget *target = [[_FutureTimerTarget alloc] init];
    target.block = block;  // This will copy the block

    // Use timerWithTimeInterval:target:selector:object:repeats: with arguments: 1
    OFTimer *t = [OFTimer timerWithTimeInterval:0
                                         target:target
                                       selector:@selector(fire:)
                                         object:nil
                                        repeats:false];
    if (!mode) [runLoop addTimer:t];
    else       [runLoop addTimer:t forMode:mode];
}

- (void)whenComplete:(FutureCompletionHandler_f ^)handler
{
    [self whenCompleteOnRunLoop:_deliveryRunLoop mode:_deliveryRunLoopMode handler:handler];
}

- (void)whenCompleteOnRunLoop:(OFRunLoop *nillable)runLoop
                         mode:(OFRunLoopMode nillable)mode
                      handler:(FutureCompletionHandler_f ^)handler
{
    id nillable v = nil;
    id nillable e = nil;
    bool already = false;

    // Ensure the handler is heap-allocated
    FutureCompletionHandler_f ^copiedHandler = [handler copy];

    @synchronized(self) {
        already = _completed;
        if (not already) {
            auto obs = [[_FutureObserver alloc] init];
            obs.runLoop = runLoop;
            obs.mode = mode;
            obs.handler = copiedHandler;
            [_observers addObject:obs];
            return;
        }

        v = _value;
        e = _exception;
    }

    // For already-completed futures, just call the handler directly if no run loop
    if (not runLoop) {
        copiedHandler(v, e);
        return;
    }

    // Schedule on run loop
    [self of_scheduleOnRunLoop:runLoop mode:mode block: ^(OFTimer *t){ copiedHandler(v, e); }];
}



- (void)of_completeWithValue:(id _Nullable)value exception:(id _Nullable)exception
{
    OFArray<_FutureObserver *> *toNotify;

    @synchronized(self) {
        if (_completed) return;

        _completed = true;
        _value = value;
        _exception = exception;

        toNotify = [_observers copy];
        [_observers removeAllObjects];
    }

    for (_FutureObserver *obs in toNotify) {
        FutureCompletionHandler_f ^h = obs.handler;
        id _Nullable v = _value;
        id _Nullable e = _exception;
        
        [self of_scheduleOnRunLoop:obs.runLoop mode:obs.mode block:^(OFTimer *t){ 
            h(v, e); 
        }];
    }
}

/* ===================== Typed combinators ===================== */

- (Future<id> *)map:(id nillable (^)(id value))block
{
    FuturePromise<id> *p = [FuturePromise promiseWithRunLoop:_deliveryRunLoop mode:_deliveryRunLoopMode];
    
    // Capture self to keep the source future alive until completion
    __typeof(self) sourceFuture = self;
    [self whenComplete:^(id nillable v, id nillable e) {
        (void)sourceFuture; // prevent premature deallocation
        if (e) { [p reject: (OFException *)e]; return; }

        @try {
            id out = block ? block(v) : v;
            [p resolve:out];
        } @catch (id ex) {
            [p reject:ex];
        }
    }];

    return p.future;
}

// - (Future<id> *)bind:(Future<id> * (^)(id value))block
// {
//     FuturePromise<id> *p = [FuturePromise promiseWithRunLoop:_deliveryRunLoop mode:_deliveryRunLoopMode];

//     [self whenComplete:^(id nillable v, id nillable e) {
//         if (e) { [p reject: (OFException *)e]; return; }

//         @try {
//             Future<id> *next = block ? block(v) : (Future<id> *)[Future resolved:v];

//             [next whenComplete:^(id nillable v2, id nillable e2) {
//                 if (e2) [p reject: (OFException *)e2];
//                 else    [p resolve:v2];
//             }];
//         } @catch (id ex) {
//             [p reject:ex];
//         }
//     }];

//     return p.future;
// }

- (Future *)catch:(id _Nullable (^)(OFException *nillable exception))block
{
    FuturePromise *p = [FuturePromise promiseWithRunLoop:_deliveryRunLoop mode:_deliveryRunLoopMode];
    
    // Capture self to keep the source future alive until completion
    __block Future *sourceFuture = self;
    [self whenComplete:^(id nillable v, id nillable e) {
        // Use sourceFuture to ensure retention
        if (sourceFuture == nil) return; // will never be true, but forces capture
        // Keep sourceFuture alive but don't release it here
        Future *keepAlive = sourceFuture;
        (void)keepAlive;
        if (not e) { [p resolve:v]; return; }
        if (not block) { [p reject: (OFException *)e]; return; }

        @try {
            id recovered = block(e);
            [p resolve:recovered];
        } @catch (id ex) {
            [p reject:ex];
        }
    }];

    return p.future;
}

- (Future *)finally:(void (^)(void))block
{
    FuturePromise *p = [FuturePromise promiseWithRunLoop:_deliveryRunLoop mode:_deliveryRunLoopMode];
    
    // Capture self to keep the source future alive until completion
    __block Future *sourceFuture = self;
    [self whenComplete:^(id _Nullable v, id _Nullable e) {
        // Use sourceFuture to ensure retention
        if (sourceFuture == nil) return; // will never be true, but forces capture
        // Keep sourceFuture alive but don't release it here
        Future *keepAlive = sourceFuture;
        (void)keepAlive;
        @try { if (block) block(); }
        @catch (id ex) { e = ex; v = nil; }

        if (e) [p reject: (OFException *)e];
        else   [p resolve:v];
    }];

    return p.future;
}

/* ===================== yay haskell ===================== */

- (id)bind:(id<Monad> (^nonnil)(id x))f
{
    // If f returns a Future, we flatten; otherwise we just resolve with whatever it returned.
    FuturePromise *p = [FuturePromise promiseWithRunLoop:_deliveryRunLoop mode:_deliveryRunLoopMode];
    
    // Capture self to keep the source future alive until completion
    __block Future *sourceFuture = self;
    [self whenComplete:^(id nillable v, id nillable e) {
        // Use sourceFuture to ensure retention
        if (sourceFuture == nil) return; // will never be true, but forces capture
        Future *localSource = sourceFuture;
        sourceFuture = nil; // Release after capture
        (void)localSource; // suppress unused warning
        
        if (e) { [p reject: (OFException *)e]; return; }

        @try {
            id<Monad> m = f ? f(v) : (id<Monad>)[Future resolved:v];

            if ([m isKindOfClass: Future.class]) {
                // Must retain the inner future until it completes
                __block Future *innerFuture = (Future *)m;
                [innerFuture whenComplete:^(id nillable v2, id nillable e2) {
                    // Use innerFuture to ensure retention
                    if (innerFuture == nil) return; // will never be true, but forces capture
                    // Don't release innerFuture here as it may still be in use
                    Future *keepAlive = innerFuture;
                    (void)keepAlive;
                    if (e2) [p reject: (OFException *)e2];
                    else    [p resolve:v2];
                }];
            } else {
                [p resolve: m];
            }
        } @catch (id ex) {
            [p reject:ex];
        }
    }];

    return p.future;
}

- (id)apply:(id<Applicative>)fa
{
    if (![fa isKindOfClass:[Future class]])
        @throw [OFInvalidArgumentException exception];

    Future *fx = (Future *)fa;

    // self : Future<(a -> b)>
    // fx   : Future<a>
    return [self bind:^id(id fblock) {
        return [fx map:^id(id x) {
            id (^func)(id) = fblock;
            return func(x);
        }];
    }];
}

@end

@implementation FuturePromise {
    Future *_future;
}

+ (instancetype)promiseWithRunLoop:(nullable OFRunLoop *)runLoop
                              mode:(nullable OFRunLoopMode)mode
{
    return [[self alloc] initWithRunLoop:runLoop mode:mode];
}

- (instancetype)initWithRunLoop:(nullable OFRunLoop *)runLoop
                           mode:(nullable OFRunLoopMode)mode
{
    self = [super init];
    _future = [[Future alloc] of_initWithRunLoop:runLoop mode:mode];
    return self;
}

- (Future *)future { return _future; }

- (void)resolve:(id)value   { [_future of_completeWithValue:value exception:nil]; }
- (void)reject:(id)exception { [_future of_completeWithValue:nil exception:exception]; }

@end
