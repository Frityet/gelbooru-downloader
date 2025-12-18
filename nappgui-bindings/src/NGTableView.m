#import "NGTableView.h"

#import "NGLayoutItem.h"
#import "NGEventListenerTarget.h"
#include <core/arrst.h>

@implementation NGTableView {
    TableView *_tableView;
    NGEventListenerTarget *_onDataTarget;
    NGEventListenerTarget *_onRowClickTarget;
    NGEventListenerTarget *_onHeaderClickTarget;
    NGEventListenerTarget *_onSelectTarget;

    NGTableRowCountProvider _rowCountProvider;
    NGTableCellTextProvider _cellTextProvider;
    NGTableCellProvider _cellProvider;
    NGTableRowClickHandler _rowClickHandler;
    NGTableHeaderClickHandler _headerClickHandler;
    NGTableSelectionHandler _selectionHandler;

    OFMutableArray<OFString *> *_cellCache;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_tableView;
}

- (instancetype)init
{
    self = [super init];
    _tableView = tableview_create();
    _cellCache = [[OFMutableArray alloc] init];
    return self;
}

- (instancetype)initWithExistingHandle:(TableView *)handle
{
    self = [super init];
    _tableView = handle;
    _cellCache = [[OFMutableArray alloc] init];
    return self;
}

- (TableView *)handle
{
    return _tableView;
}

- (void)setSize:(S2Df)size
{
    tableview_size(_tableView, size);
}

- (uint32_t)addTextColumn
{
    return tableview_add_column_text(_tableView);
}

- (void)removeColumn:(uint32_t)columnId
{
    tableview_del_column(_tableView, columnId);
}

- (uint32_t)columnCount
{
    return tableview_column_count(_tableView);
}

- (void)setColumn:(uint32_t)columnId width:(real32_t)width
{
    tableview_column_width(_tableView, columnId, width);
}

- (void)setHeaderTitle:(OFString *)title forColumn:(uint32_t)columnId
{
    tableview_header_title(_tableView, columnId, title.UTF8String);
}

- (void)setHeaderVisible:(bool)visible
{
    tableview_header_visible(_tableView, visible);
}

- (void)setHeaderClickable:(bool)clickable
{
    tableview_header_clickable(_tableView, clickable);
}

- (void)setGridVisibleHorizontal:(bool)horizontal vertical:(bool)vertical
{
    tableview_grid(_tableView, horizontal, vertical);
}

- (void)setRowHeight:(real32_t)height
{
    tableview_row_height(_tableView, height);
}

- (void)setAllowsMultipleSelection:(bool)enabled preserveSelection:(bool)preserve
{
    tableview_multisel(_tableView, enabled, preserve);
}

- (void)setColumn:(uint32_t)columnId alignment:(align_t)alignment
{
    tableview_column_align(_tableView, columnId, alignment);
}

- (void)setColumn:(uint32_t)columnId resizable:(bool)resizable
{
    tableview_column_resizable(_tableView, columnId, resizable);
}

- (void)freezeColumn:(uint32_t)columnId
{
    tableview_column_freeze(_tableView, columnId);
}

- (void)setHeaderIndicator:(uint32_t)indicator forColumn:(uint32_t)columnId
{
    tableview_header_indicator(_tableView, columnId, indicator);
}

- (void)setScrollbarsVisibleHorizontal:(bool)horizontal vertical:(bool)vertical
{
    tableview_scroll_visible(_tableView, horizontal, vertical);
}

- (void)focusRow:(uint32_t)row align:(align_t)align
{
    tableview_focus_row(_tableView, row, align);
}

- (void)selectRows:(OFArray<OFNumber *> *)rows
{
    uint32_t count = (uint32_t)rows.count;
    if (count == 0) {
        tableview_deselect_all(_tableView);
        return;
    }
    uint32_t buffer[count];
    for (uint32_t i = 0; i < count; ++i)
        buffer[i] = rows[i].unsignedLongValue;
    tableview_select(_tableView, buffer, count);
}

- (void)deselectRows:(OFArray<OFNumber *> *)rows
{
    uint32_t count = (uint32_t)rows.count;
    if (count == 0)
        return;
    uint32_t buffer[count];
    for (uint32_t i = 0; i < count; ++i)
        buffer[i] = rows[i].unsignedLongValue;
    tableview_deselect(_tableView, buffer, count);
}

- (void)deselectAllRows
{
    tableview_deselect_all(_tableView);
}

- (OFArray<OFNumber *> *)selectedRows
{
    const ArrSt(uint32_t) *sel = tableview_selected(_tableView);
    OFMutableArray<OFNumber *> *rows = [[OFMutableArray alloc] init];
    if (sel != NULL) {
        uint32_t count = arrst_size(sel, uint32_t);
        for (uint32_t i = 0; i < count; ++i) {
            uint32_t *row = arrst_get((ArrSt(uint32_t) *)sel, i, uint32_t);
            [rows addObject:[OFNumber numberWithUnsignedLong:*row]];
        }
    }
    return rows;
}

- (void)setRowCountProvider:(NGTableRowCountProvider)provider
{
    _rowCountProvider = [provider copy];
    [self attachDataListenerIfNeeded];
}

- (void)setCellTextProvider:(NGTableCellTextProvider)provider
{
    _cellTextProvider = [provider copy];
    [self attachDataListenerIfNeeded];
}

- (void)setCellProvider:(NGTableCellProvider)provider
{
    _cellProvider = [provider copy];
    [self attachDataListenerIfNeeded];
}

- (void)onRowClick:(NGTableRowClickHandler)handler
{
    _rowClickHandler = [handler copy];
    if (_rowClickHandler != nil) {
        _onRowClickTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
            const EvTbRow *row = event_params(event, EvTbRow);
            if (row != NULL)
                _rowClickHandler(row->row);
        }];
        tableview_OnRowClick(_tableView, NGListenerCreate(_onRowClickTarget));
    } else {
        tableview_OnRowClick(_tableView, NULL);
    }
}

- (void)onHeaderClick:(NGTableHeaderClickHandler)handler
{
    _headerClickHandler = [handler copy];
    if (_headerClickHandler != nil) {
        _onHeaderClickTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
            const EvButton *params = event_params(event, EvButton);
            if (params != NULL)
                _headerClickHandler(params->index);
        }];
        tableview_OnHeaderClick(_tableView, NGListenerCreate(_onHeaderClickTarget));
    } else {
        tableview_OnHeaderClick(_tableView, NULL);
    }
}

- (void)onSelectionChanged:(NGTableSelectionHandler)handler
{
    _selectionHandler = [handler copy];
    if (_selectionHandler != nil) {
        _onSelectTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
            const EvTbSel *sel = event_params(event, EvTbSel);
            OFMutableArray<OFNumber *> *rows = [[OFMutableArray alloc] init];
            if (sel != NULL && sel->sel != NULL) {
                uint32_t count = arrst_size(sel->sel, uint32_t);
                for (uint32_t i = 0; i < count; ++i) {
                    uint32_t *row = arrst_get(sel->sel, i, uint32_t);
                    [rows addObject:[OFNumber numberWithUnsignedLong:*row]];
                }
            }
            _selectionHandler(rows);
        }];
        tableview_OnSelect(_tableView, NGListenerCreate(_onSelectTarget));
    } else {
        tableview_OnSelect(_tableView, NULL);
    }
}

- (void)attachDataListenerIfNeeded
{
    if (_onDataTarget != nil)
        return;

    _onDataTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        gui_event_t type = event_type(event);
        if (type == ekGUI_EVENT_TBL_BEGIN) {
            [_cellCache removeAllObjects];
        } else if (type == ekGUI_EVENT_TBL_NROWS) {
            if (_rowCountProvider != nil) {
                uint32_t *rowsOut = event_result(event, uint32_t);
                if (rowsOut != NULL)
                    *rowsOut = _rowCountProvider();
            }
        } else if (type == ekGUI_EVENT_TBL_CELL) {
            if (_cellProvider != nil || _cellTextProvider != nil) {
                const EvTbPos *pos = event_params(event, EvTbPos);
                EvTbCell *cell = event_result(event, EvTbCell);
                if (pos != NULL && cell != NULL) {
                    OFString *text = nil;
                    const Image *icon = NULL;
                    align_t align = ekLEFT;
                    if (_cellProvider != nil) {
                        NGTableCell cellDesc = _cellProvider(pos->row, pos->col);
                        text = cellDesc.text;
                        icon = cellDesc.icon;
                        align = cellDesc.align;
                    } else if (_cellTextProvider != nil) {
                        text = _cellTextProvider(pos->row, pos->col);
                    }
                    if (text == nil)
                        text = @"";
                    [_cellCache addObject:text];
                    cell->text = [_cellCache.lastObject UTF8String];
                    cell->icon = icon;
                    cell->align = align;
                }
            }
        }
    }];
    tableview_OnData(_tableView, NGListenerCreate(_onDataTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_tableview(layout, _tableView, column, row);
}

@end
