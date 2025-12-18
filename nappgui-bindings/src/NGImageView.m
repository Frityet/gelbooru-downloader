#import "NGImageView.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGImageView {
    ImageView *_view;
    NGEventListenerTarget *_onClickTarget;
    NGEventListenerTarget *_onDrawTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_view;
}

- (instancetype)initWithExistingHandle:(ImageView *)handle
{
    self = [super init];
    _view = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _view = imageview_create();
    return self;
}

- (ImageView *)handle
{
    return _view;
}

- (void)setSize:(S2Df)size
{
    imageview_size(_view, size);
}

- (void)setScale:(gui_scale_t)scale
{
    imageview_scale(_view, scale);
}

- (void)setImage:(const Image *_Nullable)image
{
    imageview_image(_view, image);
}

- (const Image *_Nullable)image
{
    return imageview_get_image(_view);
}

- (void)onClick:(NGImageViewClickHandler)handler
{
    _onClickTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler(self);
    }];
    imageview_OnClick(_view, NGListenerCreate(_onClickTarget));
}

- (void)onDraw:(NGImageViewDrawHandler)handler
{
    _onDrawTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        const EvDraw *params = event_params(event, EvDraw);
        if (params != NULL) {
            handler(self, params->ctx, params->x, params->y, params->width, params->height);
        } else {
            handler(self, NULL, 0, 0, 0, 0);
        }
    }];
    imageview_OnOverDraw(_view, NGListenerCreate(_onDrawTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_imageview(layout, _view, column, row);
}

@end
