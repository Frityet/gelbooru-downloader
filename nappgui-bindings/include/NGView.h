#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGView;

typedef void (^NGViewDrawHandler)(NGView *view, DCtx *_Nullable context, real32_t x, real32_t y, real32_t width, real32_t height);
typedef void (^NGViewSizeHandler)(NGView *view, const EvSize *_Nullable size);
typedef void (^NGViewMouseHandler)(NGView *view, const EvMouse *_Nullable event);
typedef void (^NGViewWheelHandler)(NGView *view, const EvWheel *_Nullable event);
typedef void (^NGViewKeyHandler)(NGView *view, const EvKey *_Nullable event);
typedef void (^NGViewScrollHandler)(NGView *view, const EvScroll *_Nullable event);
typedef void (^NGViewSimpleHandler)(NGView *view);

@interface NGView : NGControl <NGLayoutItem>

@property (nonatomic, readonly) View *handle;

- (instancetype)initWithExistingHandle:(View *)handle;
- (instancetype)init;
- (instancetype)initWithScroll:(bool)scroll border:(bool)border;
- (instancetype)initWithScroll:(bool)scroll;

- (void)setSize:(S2Df)size;
- (void)setContentSize:(S2Df)size line:(S2Df)line;
- (void)setScrollX:(real32_t)position;
- (void)setScrollY:(real32_t)position;
- (S2Df)scrollSize;
- (void)setScrollbarsVisibleHorizontal:(bool)horizontal vertical:(bool)vertical;
- (void)getViewportPosition:(V2Df *_Nullable)position size:(S2Df *_Nullable)size;
- (real32_t)pointScale;
- (void)allowTab:(bool)allow;
- (void)update;

- (void)onDraw:(NGViewDrawHandler)handler;
- (void)onOverlay:(NGViewDrawHandler)handler;
- (void)onResize:(NGViewSizeHandler)handler;
- (void)onEnter:(NGViewMouseHandler)handler;
- (void)onExit:(NGViewMouseHandler)handler;
- (void)onMove:(NGViewMouseHandler)handler;
- (void)onDown:(NGViewMouseHandler)handler;
- (void)onUp:(NGViewMouseHandler)handler;
- (void)onClick:(NGViewMouseHandler)handler;
- (void)onDrag:(NGViewMouseHandler)handler;
- (void)onWheel:(NGViewWheelHandler)handler;
- (void)onKeyDown:(NGViewKeyHandler)handler;
- (void)onKeyUp:(NGViewKeyHandler)handler;
- (void)onFocus:(NGViewSimpleHandler)handler;
- (void)onResignFocus:(NGViewSimpleHandler)handler;
- (void)onAcceptFocus:(NGViewSimpleHandler)handler;
- (void)onScroll:(NGViewScrollHandler)handler;

@end

OF_ASSUME_NONNULL_END
