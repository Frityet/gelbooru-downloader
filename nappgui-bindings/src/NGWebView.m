#import "NGWebView.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGWebView {
    WebView *_webView;
    NGEventListenerTarget *_onFocusTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_webView;
}

- (instancetype)initWithExistingHandle:(WebView *)handle
{
    self = [super init];
    _webView = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _webView = webview_create();
    return self;
}

- (WebView *)handle
{
    return _webView;
}

- (void)setSize:(S2Df)size
{
    webview_size(_webView, size);
}

- (void)navigateTo:(OFString *)url
{
    webview_navigate(_webView, url.UTF8String);
}

- (void)goBack
{
    webview_back(_webView);
}

- (void)goForward
{
    webview_forward(_webView);
}

- (void)onFocus:(NGWebViewFocusHandler)handler
{
    _onFocusTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler();
    }];
    webview_OnFocus(_webView, NGListenerCreate(_onFocusTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_webview(layout, _webView, column, row);
}

@end
