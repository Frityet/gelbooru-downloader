#import "NGLabel.h"
#import "NGLayoutItem.h"

@implementation NGLabel {
    Label *_label;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_label;
}

- (instancetype)initWithExistingHandle:(Label *)handle
{
    self = [super init];
    _label = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _label = label_create();
    return self;
}

- (Label *)handle
{
    return _label;
}

- (void)setText:(OFString *)text
{
    label_text(_label, text.UTF8String);
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_label(layout, _label, column, row);
}

@end
