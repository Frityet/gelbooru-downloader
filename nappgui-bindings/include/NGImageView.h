#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGImageView;

typedef void (^NGImageViewClickHandler)(NGImageView *imageView);
typedef void (^NGImageViewDrawHandler)(NGImageView *imageView, DCtx *_Nullable context, real32_t x, real32_t y, real32_t width, real32_t height);

@interface NGImageView : NGControl <NGLayoutItem>

@property (nonatomic, readonly) ImageView *handle;

- (instancetype)initWithExistingHandle:(ImageView *)handle;
- (instancetype)init;

- (void)setSize:(S2Df)size;
- (void)setScale:(gui_scale_t)scale;
- (void)setImage:(const Image *_Nullable)image;
- (const Image *_Nullable)image;

- (void)onClick:(NGImageViewClickHandler)handler;
- (void)onDraw:(NGImageViewDrawHandler)handler;

@end

OF_ASSUME_NONNULL_END
