#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGListBox;

typedef void (^NGListBoxSelectHandler)(NGListBox *listBox, uint32_t index, OFString *_Nullable text);

@interface NGListBox : NGControl <NGLayoutItem>

@property (nonatomic, readonly) ListBox *handle;

- (instancetype)initWithExistingHandle:(ListBox *)handle;
- (instancetype)init;

- (void)setSize:(S2Df)size;
- (void)setShowsCheckboxes:(bool)show;
- (void)setAllowsMultipleSelection:(bool)enabled;

- (void)addItem:(OFString *)text;
- (void)setItem:(OFString *)text atIndex:(uint32_t)index;
- (void)removeItemAtIndex:(uint32_t)index;
- (void)clear;

- (uint32_t)count;
- (OFString *)itemTextAtIndex:(uint32_t)index;

- (void)setColor:(color_t)color atIndex:(uint32_t)index;
- (void)setChecked:(bool)checked atIndex:(uint32_t)index;
- (bool)isCheckedAtIndex:(uint32_t)index;

- (void)setSelected:(bool)selected atIndex:(uint32_t)index;
- (bool)isSelectedAtIndex:(uint32_t)index;
- (uint32_t)selectedIndex;

- (real32_t)rowHeight;

- (void)onSelect:(NGListBoxSelectHandler)handler;

@end

OF_ASSUME_NONNULL_END
