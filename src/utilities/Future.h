#import "common.h"

#import "Functional.h"

$assume_nonnil_begin

@interface Future<__covariant T> : OFObject<Monad>

typedef void FutureCompletionHandler_f(nillable T value, OFException *nillable error);

enum FutureStatus {
    FutureStatus_COMPLETED,
    FutureStatus_RESOLVED,
    FutureStatus_REJECTED
};

@property(nonatomic, readonly) enum FutureStatus status;
@property(nonatomic, readonly, nullable) T value;
@property(nonatomic, readonly, nullable) OFException *error;

@property (readonly, nonatomic, nullable) OFRunLoop *deliveryRunLoop;
@property (readonly, nonatomic, nullable) OFRunLoopMode deliveryRunLoopMode;

+ (instancetype)resolved: (T nillable)value;
+ (instancetype)rejected: (OFException *)exception;

+ (instancetype)pure:(id)x;

/// Start immediately; callbacks are delivered onto (runLoop, mode).
+ (instancetype)futureWithRunLoop:(OFRunLoop *nillable)runLoop
                             mode:(OFRunLoopMode nillable)mode
                            start:(void (^)(void (^resolve)(T nillable value), void (^reject)(OFException *nillable exception)))start;
//default run loop with nil mode
+ (instancetype)futureWithAsyncBlock:(void (^)(void (^resolve)(T nillable value), void (^reject)(OFException *nillable exception)))start;
                            
- (instancetype)deliverOnRunLoop:(OFRunLoop *nillable) runLoop mode:(OFRunLoopMode nillable)mode;

+ (Future<OFArray<T> *> *)all:(OFArray<Future<T> *> *)futures;
- (void)whenComplete:(FutureCompletionHandler_f ^)handler;
- (void)whenCompleteOnRunLoop:(OFRunLoop *nillable)runLoop mode:(OFRunLoopMode nillable)mode handler:(FutureCompletionHandler_f ^)handler;

- (Future<id> *)map:(id nillable (^)(T value))block;
// - (Future<id> *)bind:(Future<id> * (^)(T value))block;

- (Future<T> *)catch:(T nillable (^)(OFException *nillable exception))block;
- (Future<T> *)finally:(void (^)(void))block;

@end


@interface FuturePromise<T> : OFObject

@property (readonly, nonatomic) Future<T> *future;

+ (instancetype)promiseWithRunLoop:(OFRunLoop *nillable)runLoop
                              mode:(OFRunLoopMode nillable)mode;

- (void)resolve:(T nillable)value;
- (void)reject:(OFException *)exception;

@end


$assume_nonnil_end
