#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"

OF_ASSUME_NONNULL_BEGIN

@class NGLayout;

@interface NGPanel : NGControl

@property (nonatomic, readonly) Panel *handle;

- (instancetype)initWithExistingHandle:(Panel *)handle;
- (instancetype)init;
- (uint32_t)setLayout:(NGLayout *)layout;

@end

OF_ASSUME_NONNULL_END
