#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

typedef void (^NGWebViewFocusHandler)(void);

@interface NGWebView : NGControl <NGLayoutItem>

@property (nonatomic, readonly) WebView *handle;

- (instancetype)initWithExistingHandle:(WebView *)handle;
- (instancetype)init;

- (void)setSize:(S2Df)size;
- (void)navigateTo:(OFString *)url;
- (void)goBack;
- (void)goForward;

- (void)onFocus:(NGWebViewFocusHandler)handler;

@end

OF_ASSUME_NONNULL_END
