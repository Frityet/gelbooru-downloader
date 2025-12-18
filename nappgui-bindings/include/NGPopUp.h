#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGPopUp;

typedef void (^NGPopUpSelectHandler)(NGPopUp *popUp, uint32_t index, OFString *_Nullable text);

@interface NGPopUp : NGControl <NGLayoutItem>

@property (nonatomic, readonly) PopUp *handle;

- (instancetype)initWithExistingHandle:(PopUp *)handle;
- (instancetype)init;

- (void)setTooltip:(OFString *_Nullable)text;

- (void)addItem:(OFString *)text;
- (void)setItem:(OFString *)text atIndex:(uint32_t)index;
- (void)insertItem:(OFString *)text atIndex:(uint32_t)index;
- (void)removeItemAtIndex:(uint32_t)index;
- (void)clear;

- (uint32_t)count;
- (void)setListHeight:(uint32_t)items;

- (void)selectIndex:(uint32_t)index;
- (uint32_t)selectedIndex;

- (OFString *)itemTextAtIndex:(uint32_t)index;

- (void)onSelect:(NGPopUpSelectHandler)handler;

@end

OF_ASSUME_NONNULL_END
