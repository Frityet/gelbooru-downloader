#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGCombo;

typedef void (^NGComboSelectHandler)(NGCombo *combo, uint32_t selectedIndex);

@interface NGCombo : NGControl <NGLayoutItem>

@property (nonatomic, readonly) Combo *handle;

- (instancetype)initWithExistingHandle:(Combo *)handle;
- (instancetype)init;

- (void)setText:(OFString *)text;
- (OFString *)text;

- (void)addItem:(OFString *)text;
- (void)setItem:(OFString *)text atIndex:(uint32_t)index;
- (void)insertItem:(OFString *)text atIndex:(uint32_t)index;
- (void)removeItemAtIndex:(uint32_t)index;
- (void)clear;

- (uint32_t)count;

- (void)selectIndex:(uint32_t)index;
- (uint32_t)selectedIndex;

- (OFString *)itemTextAtIndex:(uint32_t)index;

- (void)onSelect:(NGComboSelectHandler)handler;

@end

OF_ASSUME_NONNULL_END
