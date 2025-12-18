#import "NGEventListenerTarget.h"

@implementation NGEventListenerTarget

- (instancetype)initWithHandler:(NGEventHandler)handler
{
    self = [super init];
    _handler = [handler copy];
    return self;
}

@end

static void NGEventListenerTrampoline(void *obj, Event *event)
{
    NGEventListenerTarget *target = (__bridge NGEventListenerTarget *)obj;
    target.handler(event);
}

Listener *NGListenerCreate(NGEventListenerTarget *target)
{
    return listener_imp((__bridge void *)target, NGEventListenerTrampoline);
}
