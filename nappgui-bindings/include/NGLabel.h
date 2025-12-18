#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@interface NGLabel : NGControl <NGLayoutItem>

@property (nonatomic, readonly) Label *handle;

- (instancetype)initWithExistingHandle:(Label *)handle;

- (instancetype)init;
- (void)setText:(OFString *)text;

@end

OF_ASSUME_NONNULL_END
