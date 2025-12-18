#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGControl.h"
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@interface NGTableView : NGControl <NGLayoutItem>

@property (nonatomic, readonly) TableView *handle;

- (instancetype)init;
- (instancetype)initWithExistingHandle:(TableView *)handle;

- (void)setSize:(S2Df)size;
- (uint32_t)addTextColumn;
- (void)removeColumn:(uint32_t)columnId;
- (uint32_t)columnCount;
- (void)setColumn:(uint32_t)columnId width:(real32_t)width;
- (void)setHeaderTitle:(OFString *)title forColumn:(uint32_t)columnId;
- (void)setHeaderVisible:(bool)visible;
- (void)setHeaderClickable:(bool)clickable;
- (void)setGridVisibleHorizontal:(bool)horizontal vertical:(bool)vertical;
- (void)setRowHeight:(real32_t)height;
- (void)setAllowsMultipleSelection:(bool)enabled preserveSelection:(bool)preserve;
- (void)setColumn:(uint32_t)columnId alignment:(align_t)alignment;
- (void)setColumn:(uint32_t)columnId resizable:(bool)resizable;
- (void)freezeColumn:(uint32_t)columnId;
- (void)setHeaderIndicator:(uint32_t)indicator forColumn:(uint32_t)columnId;
- (void)setScrollbarsVisibleHorizontal:(bool)horizontal vertical:(bool)vertical;
- (void)focusRow:(uint32_t)row align:(align_t)align;
- (void)selectRows:(OFArray<OFNumber *> *)rows;
- (void)deselectRows:(OFArray<OFNumber *> *)rows;
- (void)deselectAllRows;
- (OFArray<OFNumber *> *)selectedRows;

typedef uint32_t (^NGTableRowCountProvider)(void);
typedef OFString *_Nullable (^NGTableCellTextProvider)(uint32_t row, uint32_t column);
typedef struct
{
    OFString *_Nullable text;
    const Image *_Nullable icon;
    align_t align;
} NGTableCell;
typedef NGTableCell (^NGTableCellProvider)(uint32_t row, uint32_t column);
typedef void (^NGTableRowClickHandler)(uint32_t row);
typedef void (^NGTableHeaderClickHandler)(uint32_t column);
typedef void (^NGTableSelectionHandler)(OFArray<OFNumber *> *selectedRows);

- (void)setRowCountProvider:(NGTableRowCountProvider)provider;
- (void)setCellTextProvider:(NGTableCellTextProvider)provider;
- (void)setCellProvider:(NGTableCellProvider)provider;
- (void)onRowClick:(NGTableRowClickHandler)handler;
- (void)onHeaderClick:(NGTableHeaderClickHandler)handler;
- (void)onSelectionChanged:(NGTableSelectionHandler)handler;

@end

OF_ASSUME_NONNULL_END
