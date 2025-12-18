#import "NGSplitView.h"

#import "NGLayoutItem.h"
#import "NGPanel.h"
#import "NGTextView.h"
#import "NGView.h"
#import "NGWebView.h"

@implementation NGSplitView {
    SplitView *_splitView;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_splitView;
}

- (instancetype)initWithExistingHandle:(SplitView *)handle
{
    self = [super init];
    _splitView = handle;
    return self;
}

- (instancetype)initHorizontal
{
    self = [super init];
    _splitView = splitview_horizontal();
    return self;
}

- (instancetype)initVertical
{
    self = [super init];
    _splitView = splitview_vertical();
    return self;
}

- (SplitView *)handle
{
    return _splitView;
}

- (void)setView:(NGView *)view tabStop:(bool)tabStop
{
    splitview_view(_splitView, view.handle, tabStop);
}

- (void)setTextView:(NGTextView *)textView tabStop:(bool)tabStop
{
    splitview_textview(_splitView, textView.handle, tabStop);
}

- (void)setWebView:(NGWebView *)webView tabStop:(bool)tabStop
{
    splitview_webview(_splitView, webView.handle, tabStop);
}

- (void)setSplitView:(NGSplitView *)splitView
{
    splitview_splitview(_splitView, splitView.handle);
}

- (void)setPanel:(NGPanel *)panel
{
    splitview_panel(_splitView, panel.handle);
}

- (void)setPosition:(real32_t)position mode:(split_mode_t)mode
{
    splitview_pos(_splitView, mode, position);
}

- (real32_t)positionForMode:(split_mode_t)mode
{
    return splitview_get_pos(_splitView, mode);
}

- (void)setFirstVisible:(bool)visible
{
    splitview_visible0(_splitView, visible);
}

- (void)setSecondVisible:(bool)visible
{
    splitview_visible1(_splitView, visible);
}

- (void)setFirstMinimumSize:(real32_t)size
{
    splitview_minsize0(_splitView, size);
}

- (void)setSecondMinimumSize:(real32_t)size
{
    splitview_minsize1(_splitView, size);
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_splitview(layout, _splitView, column, row);
}

@end
