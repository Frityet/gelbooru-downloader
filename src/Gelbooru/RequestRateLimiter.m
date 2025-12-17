#import "Gelbooru/RequestRateLimiter.h"

@implementation RequestRateLimiter {
    OFMutableArray<void (^)(void)> *queue;
    OFTimer *nillable timer;
}

- (instancetype)initWithRequestsPerSecond:(size_t)rps
{
    self = [super init];
    _requestsPerSecond = rps ? rps : 1;
    queue = [OFMutableArray array];
    timer = nilptr;
    return self;
}

- (void)enqueue:(void (^)(void))block
{
    if (not block) return;

    @synchronized(self) {
        [queue addObject: [block copy]];
        [self startTimerIfNeededLocked];
    }
}

- (void)startTimerIfNeededLocked
{
    if (timer) return;

    OFTimeInterval interval = 1.0 / (double)_requestsPerSecond;
    timer = [OFTimer scheduledTimerWithTimeInterval:interval
                                             target:self
                                           selector:@selector(fire:)
                                             object:nilptr
                                            repeats:true];
}

- (void)fire:(OFTimer *)t
{
    void (^nillable block)(void) = nilptr;

    @synchronized(self) {
        if (queue.count > 0) {
            block = queue.firstObject;
            [queue removeObjectAtIndex:0];
        } else {
            [timer invalidate];
            timer = nilptr;
        }
    }

    if (block) block();
}

@end
