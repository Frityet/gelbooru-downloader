#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGEdit;

typedef void (^NGEditChangeHandler)(NGEdit *edit, OFString *text);

@interface NGEdit : NGControl <NGLayoutItem>

@property (nonatomic, readonly) Edit *handle;

- (instancetype)initWithExistingHandle:(Edit *)handle;
- (instancetype)init;
- (instancetype)initMultiline;

- (void)setText:(OFString *)text;
- (OFString *)text;

- (void)setPlaceholder:(OFString *)text;
- (void)setEditable:(bool)editable;
- (void)setPasswordMode:(bool)enabled;

- (void)onChange:(NGEditChangeHandler)handler;

@end

OF_ASSUME_NONNULL_END
