#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGView;
@class NGTextView;
@class NGWebView;
@class NGSplitView;
@class NGPanel;

@interface NGSplitView : NGControl <NGLayoutItem>

@property (nonatomic, readonly) SplitView *handle;

- (instancetype)initWithExistingHandle:(SplitView *)handle;
- (instancetype)initHorizontal;
- (instancetype)initVertical;

- (void)setView:(NGView *)view tabStop:(bool)tabStop;
- (void)setTextView:(NGTextView *)textView tabStop:(bool)tabStop;
- (void)setWebView:(NGWebView *)webView tabStop:(bool)tabStop;
- (void)setSplitView:(NGSplitView *)splitView;
- (void)setPanel:(NGPanel *)panel;

- (void)setPosition:(real32_t)position mode:(split_mode_t)mode;
- (real32_t)positionForMode:(split_mode_t)mode;

- (void)setFirstVisible:(bool)visible;
- (void)setSecondVisible:(bool)visible;

- (void)setFirstMinimumSize:(real32_t)size;
- (void)setSecondMinimumSize:(real32_t)size;

@end

OF_ASSUME_NONNULL_END
