#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@interface NGTextView : NGControl <NGLayoutItem>

@property (nonatomic, readonly) TextView *handle;

- (instancetype)initWithExistingHandle:(TextView *)handle;
- (instancetype)init;
- (void)clear;
- (void)writeText:(OFString *)text;
- (void)appendLine:(OFString *)text;

@end

OF_ASSUME_NONNULL_END
