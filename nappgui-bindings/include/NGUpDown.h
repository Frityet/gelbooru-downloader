#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGUpDown;

typedef void (^NGUpDownClickHandler)(NGUpDown *upDown, bool incrementing);

@interface NGUpDown : NGControl <NGLayoutItem>

@property (nonatomic, readonly) UpDown *handle;

- (instancetype)initWithExistingHandle:(UpDown *)handle;
- (instancetype)init;

- (void)setTooltip:(OFString *_Nullable)text;
- (void)onClick:(NGUpDownClickHandler)handler;

@end

OF_ASSUME_NONNULL_END
