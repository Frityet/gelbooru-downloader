#import "common.h"

$assume_nonnil_begin

/// Simple timer-driven rate limiter that schedules at most `requestsPerSecond`
/// blocks per second. Blocks are executed on the current run loop.
@interface RequestRateLimiter : OFObject

@property(readonly, nonatomic) size_t requestsPerSecond;

- (instancetype)initWithRequestsPerSecond:(size_t)rps;
- (void)enqueue:(void (^)(void))block;

@end

$assume_nonnil_end
