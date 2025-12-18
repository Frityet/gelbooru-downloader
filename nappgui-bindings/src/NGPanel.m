#import "NGPanel.h"

#import "NGLayout.h"

@implementation NGPanel {
    Panel *_panel;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_panel;
}

- (instancetype)initWithExistingHandle:(Panel *)handle
{
    self = [super init];
    _panel = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _panel = panel_create();
    return self;
}

- (Panel *)handle
{
    return _panel;
}

- (uint32_t)setLayout:(NGLayout *)layout
{
    return panel_layout(_panel, layout.handle);
}

@end
