#import "NGButton.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGButton {
    Button *_button;
    NGEventListenerTarget *_onClickTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_button;
}

- (instancetype)initWithExistingHandle:(Button *)handle
{
    self = [super init];
    _button = handle;
    return self;
}

- (instancetype)initPush
{
    self = [super init];
    _button = button_push();
    return self;
}

- (Button *)handle
{
    return _button;
}

- (void)setText:(OFString *)text
{
    button_text(_button, text.UTF8String);
}

- (void)onClick:(void (^)(void))handler
{
    _onClickTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler();
    }];
    button_OnClick(_button, NGListenerCreate(_onClickTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_button(layout, _button, column, row);
}

@end
