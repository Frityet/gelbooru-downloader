#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@interface NGProgress : NGControl <NGLayoutItem>

@property (nonatomic, readonly) Progress *handle;

- (instancetype)initWithExistingHandle:(Progress *)handle;
- (instancetype)init;

- (void)setIndeterminate:(bool)running;
- (void)setValue:(real32_t)value;

@end

OF_ASSUME_NONNULL_END
