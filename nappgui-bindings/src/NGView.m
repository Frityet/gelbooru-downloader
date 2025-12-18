#import "NGView.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGView {
    View *_view;
    NGEventListenerTarget *_onDrawTarget;
    NGEventListenerTarget *_onOverlayTarget;
    NGEventListenerTarget *_onResizeTarget;
    NGEventListenerTarget *_onEnterTarget;
    NGEventListenerTarget *_onExitTarget;
    NGEventListenerTarget *_onMoveTarget;
    NGEventListenerTarget *_onDownTarget;
    NGEventListenerTarget *_onUpTarget;
    NGEventListenerTarget *_onClickTarget;
    NGEventListenerTarget *_onDragTarget;
    NGEventListenerTarget *_onWheelTarget;
    NGEventListenerTarget *_onKeyDownTarget;
    NGEventListenerTarget *_onKeyUpTarget;
    NGEventListenerTarget *_onFocusTarget;
    NGEventListenerTarget *_onResignFocusTarget;
    NGEventListenerTarget *_onAcceptFocusTarget;
    NGEventListenerTarget *_onScrollTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_view;
}

- (instancetype)initWithExistingHandle:(View *)handle
{
    self = [super init];
    _view = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _view = view_create();
    return self;
}

- (instancetype)initWithScroll:(bool)scroll
{
    return [self initWithScroll:scroll border:false];
}

- (instancetype)initWithScroll:(bool)scroll border:(bool)border
{
    self = [super init];
    _view = view_custom(scroll, border);
    return self;
}

- (View *)handle
{
    return _view;
}

- (void)setSize:(S2Df)size
{
    view_size(_view, size);
}

- (void)setContentSize:(S2Df)size line:(S2Df)line
{
    view_content_size(_view, size, line);
}

- (void)setScrollX:(real32_t)position
{
    view_scroll_x(_view, position);
}

- (void)setScrollY:(real32_t)position
{
    view_scroll_y(_view, position);
}

- (S2Df)scrollSize
{
    real32_t width = 0;
    real32_t height = 0;
    view_scroll_size(_view, &width, &height);
    return s2df(width, height);
}

- (void)setScrollbarsVisibleHorizontal:(bool)horizontal vertical:(bool)vertical
{
    view_scroll_visible(_view, horizontal, vertical);
}

- (void)getViewportPosition:(V2Df *_Nullable)position size:(S2Df *_Nullable)size
{
    view_viewport(_view, position, size);
}

- (real32_t)pointScale
{
    real32_t scale = 1;
    view_point_scale(_view, &scale);
    return scale;
}

- (void)allowTab:(bool)allow
{
    view_allow_tab(_view, allow);
}

- (void)update
{
    view_update(_view);
}

- (void)onDraw:(NGViewDrawHandler)handler
{
    _onDrawTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        const EvDraw *params = event_params(event, EvDraw);
        if (params != NULL)
            handler(self, params->ctx, params->x, params->y, params->width, params->height);
        else
            handler(self, NULL, 0, 0, 0, 0);
    }];
    view_OnDraw(_view, NGListenerCreate(_onDrawTarget));
}

- (void)onOverlay:(NGViewDrawHandler)handler
{
    _onOverlayTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        const EvDraw *params = event_params(event, EvDraw);
        if (params != NULL)
            handler(self, params->ctx, params->x, params->y, params->width, params->height);
        else
            handler(self, NULL, 0, 0, 0, 0);
    }];
    view_OnOverlay(_view, NGListenerCreate(_onOverlayTarget));
}

- (void)onResize:(NGViewSizeHandler)handler
{
    _onResizeTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        const EvSize *params = event_params(event, EvSize);
        handler(self, params);
    }];
    view_OnSize(_view, NGListenerCreate(_onResizeTarget));
}

- (void)onEnter:(NGViewMouseHandler)handler
{
    _onEnterTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvMouse));
    }];
    view_OnEnter(_view, NGListenerCreate(_onEnterTarget));
}

- (void)onExit:(NGViewMouseHandler)handler
{
    _onExitTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvMouse));
    }];
    view_OnExit(_view, NGListenerCreate(_onExitTarget));
}

- (void)onMove:(NGViewMouseHandler)handler
{
    _onMoveTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvMouse));
    }];
    view_OnMove(_view, NGListenerCreate(_onMoveTarget));
}

- (void)onDown:(NGViewMouseHandler)handler
{
    _onDownTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvMouse));
    }];
    view_OnDown(_view, NGListenerCreate(_onDownTarget));
}

- (void)onUp:(NGViewMouseHandler)handler
{
    _onUpTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvMouse));
    }];
    view_OnUp(_view, NGListenerCreate(_onUpTarget));
}

- (void)onClick:(NGViewMouseHandler)handler
{
    _onClickTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvMouse));
    }];
    view_OnClick(_view, NGListenerCreate(_onClickTarget));
}

- (void)onDrag:(NGViewMouseHandler)handler
{
    _onDragTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvMouse));
    }];
    view_OnDrag(_view, NGListenerCreate(_onDragTarget));
}

- (void)onWheel:(NGViewWheelHandler)handler
{
    _onWheelTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvWheel));
    }];
    view_OnWheel(_view, NGListenerCreate(_onWheelTarget));
}

- (void)onKeyDown:(NGViewKeyHandler)handler
{
    _onKeyDownTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvKey));
    }];
    view_OnKeyDown(_view, NGListenerCreate(_onKeyDownTarget));
}

- (void)onKeyUp:(NGViewKeyHandler)handler
{
    _onKeyUpTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvKey));
    }];
    view_OnKeyUp(_view, NGListenerCreate(_onKeyUpTarget));
}

- (void)onFocus:(NGViewSimpleHandler)handler
{
    _onFocusTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler(self);
    }];
    view_OnFocus(_view, NGListenerCreate(_onFocusTarget));
}

- (void)onResignFocus:(NGViewSimpleHandler)handler
{
    _onResignFocusTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler(self);
    }];
    view_OnResignFocus(_view, NGListenerCreate(_onResignFocusTarget));
}

- (void)onAcceptFocus:(NGViewSimpleHandler)handler
{
    _onAcceptFocusTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler(self);
    }];
    view_OnAcceptFocus(_view, NGListenerCreate(_onAcceptFocusTarget));
}

- (void)onScroll:(NGViewScrollHandler)handler
{
    _onScrollTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        handler(self, event_params(event, EvScroll));
    }];
    view_OnScroll(_view, NGListenerCreate(_onScrollTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_view(layout, _view, column, row);
}

@end
