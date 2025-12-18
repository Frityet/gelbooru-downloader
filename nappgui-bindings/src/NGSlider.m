#import "NGSlider.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGSlider {
    Slider *_slider;
    NGEventListenerTarget *_onChangeTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_slider;
}

- (instancetype)initWithExistingHandle:(Slider *)handle
{
    self = [super init];
    _slider = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _slider = slider_create();
    return self;
}

- (instancetype)initVertical
{
    self = [super init];
    _slider = slider_vertical();
    return self;
}

- (Slider *)handle
{
    return _slider;
}

- (void)setSteps:(uint32_t)steps
{
    slider_steps(_slider, steps);
}

- (void)setValue:(real32_t)value
{
    slider_value(_slider, value);
}

- (real32_t)value
{
    return slider_get_value(_slider);
}

- (void)onChange:(NGSliderChangeHandler)handler
{
    _onChangeTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler(self, self.value);
    }];
    slider_OnMoved(_slider, NGListenerCreate(_onChangeTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_slider(layout, _slider, column, row);
}

@end
