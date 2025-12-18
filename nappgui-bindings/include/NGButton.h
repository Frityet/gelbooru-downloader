#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@interface NGButton : NGControl <NGLayoutItem>

@property (nonatomic, readonly) Button *handle;

- (instancetype)initWithExistingHandle:(Button *)handle;
- (instancetype)initPush;
- (void)setText:(OFString *)text;
- (void)onClick:(void (^)(void))handler;

@end

OF_ASSUME_NONNULL_END
