#import "NGUpDown.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGUpDown {
    UpDown *_upDown;
    NGEventListenerTarget *_onClickTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_upDown;
}

- (instancetype)initWithExistingHandle:(UpDown *)handle
{
    self = [super init];
    _upDown = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _upDown = updown_create();
    return self;
}

- (UpDown *)handle
{
    return _upDown;
}

- (void)setTooltip:(OFString *_Nullable)text
{
    const char *raw = text != nil ? text.UTF8String : NULL;
    updown_tooltip(_upDown, raw);
}

- (void)onClick:(NGUpDownClickHandler)handler
{
    _onClickTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        const EvButton *params = event_params(event, EvButton);
        bool increment = params != NULL ? (params->index == 0) : false;
        handler(self, increment);
    }];
    updown_OnClick(_upDown, NGListenerCreate(_onClickTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_updown(layout, _upDown, column, row);
}

@end
