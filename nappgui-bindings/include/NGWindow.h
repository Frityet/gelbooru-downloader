#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>

OF_ASSUME_NONNULL_BEGIN

@class NGPanel;

@interface NGWindow : OFObject

@property (nonatomic, readonly) Window *handle;

- (instancetype)initWithFlags:(uint32_t)flags;

- (void)setTitle:(OFString *)title;
- (void)setOrigin:(V2Df)origin;
- (void)setPanel:(NGPanel *)panel;

- (void)show;
- (void)hide;

- (void)onClose:(void (^)(void))handler;

@end

OF_ASSUME_NONNULL_END
