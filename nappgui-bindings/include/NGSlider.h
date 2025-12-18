#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGSlider;

typedef void (^NGSliderChangeHandler)(NGSlider *slider, real32_t value);

@interface NGSlider : NGControl <NGLayoutItem>

@property (nonatomic, readonly) Slider *handle;

- (instancetype)initWithExistingHandle:(Slider *)handle;
- (instancetype)init;
- (instancetype)initVertical;

- (void)setSteps:(uint32_t)steps;
- (void)setValue:(real32_t)value;
- (real32_t)value;

- (void)onChange:(NGSliderChangeHandler)handler;

@end

OF_ASSUME_NONNULL_END
