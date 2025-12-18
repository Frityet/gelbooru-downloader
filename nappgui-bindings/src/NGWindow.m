#import "NGWindow.h"

#import "NGEventListenerTarget.h"
#import "NGPanel.h"

@implementation NGWindow {
    Window *_window;
    NGEventListenerTarget *_onCloseTarget;
}

- (instancetype)initWithFlags:(uint32_t)flags
{
    self = [super init];
    _window = window_create(flags);
    return self;
}

- (void)dealloc
{
    if (_window != NULL)
        window_destroy(&_window);
}

- (Window *)handle
{
    return _window;
}

- (void)setTitle:(OFString *)title
{
    window_title(_window, title.UTF8String);
}

- (void)setOrigin:(V2Df)origin
{
    window_origin(_window, origin);
}

- (void)setPanel:(NGPanel *)panel
{
    window_panel(_window, panel.handle);
}

- (void)show
{
    window_show(_window);
}

- (void)hide
{
    window_hide(_window);
}

- (void)onClose:(void (^)(void))handler
{
    _onCloseTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *) {
        handler();
    }];
    window_OnClose(_window, NGListenerCreate(_onCloseTarget));
}

@end
