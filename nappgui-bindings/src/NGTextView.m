#import "NGTextView.h"
#import "NGLayoutItem.h"

@implementation NGTextView {
    TextView *_view;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_view;
}

- (instancetype)initWithExistingHandle:(TextView *)handle
{
    self = [super init];
    _view = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _view = textview_create();
    return self;
}

- (TextView *)handle
{
    return _view;
}

- (void)clear
{
    textview_clear(_view);
}

- (void)writeText:(OFString *)text
{
    textview_writef(_view, text.UTF8String);
}

- (void)appendLine:(OFString *)text
{
    textview_printf(_view, "%s\n", text.UTF8String);
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_textview(layout, _view, column, row);
}

@end
