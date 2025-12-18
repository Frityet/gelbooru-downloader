#import "NGListBox.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGListBox {
    ListBox *_listBox;
    NGEventListenerTarget *_onSelectTarget;
    bool _allowsMultipleSelection;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_listBox;
}

- (instancetype)initWithExistingHandle:(ListBox *)handle
{
    self = [super init];
    _listBox = handle;
    _allowsMultipleSelection = false;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _listBox = listbox_create();
    _allowsMultipleSelection = false;
    return self;
}

- (ListBox *)handle
{
    return _listBox;
}

- (void)setSize:(S2Df)size
{
    listbox_size(_listBox, size);
}

- (void)setShowsCheckboxes:(bool)show
{
    listbox_checkbox(_listBox, show);
}

- (void)setAllowsMultipleSelection:(bool)enabled
{
    _allowsMultipleSelection = enabled;
    listbox_multisel(_listBox, enabled);
}

- (void)addItem:(OFString *)text
{
    listbox_add_elem(_listBox, text.UTF8String, NULL);
}

- (void)setItem:(OFString *)text atIndex:(uint32_t)index
{
    listbox_set_elem(_listBox, index, text.UTF8String, NULL);
}

- (void)removeItemAtIndex:(uint32_t)index
{
    listbox_del_elem(_listBox, index);
}

- (void)clear
{
    listbox_clear(_listBox);
}

- (uint32_t)count
{
    return listbox_count(_listBox);
}

- (OFString *)itemTextAtIndex:(uint32_t)index
{
    const char_t *raw = listbox_get_text(_listBox, index);
    return [OFString stringWithUTF8String:(const char *)raw];
}

- (void)setColor:(color_t)color atIndex:(uint32_t)index
{
    listbox_color(_listBox, index, color);
}

- (void)setChecked:(bool)checked atIndex:(uint32_t)index
{
    listbox_check(_listBox, index, checked);
}

- (bool)isCheckedAtIndex:(uint32_t)index
{
    return listbox_checked(_listBox, index);
}

- (void)setSelected:(bool)selected atIndex:(uint32_t)index
{
    listbox_select(_listBox, index, selected);
}

- (bool)isSelectedAtIndex:(uint32_t)index
{
    return listbox_selected(_listBox, index);
}

- (uint32_t)selectedIndex
{
    if (_allowsMultipleSelection)
        return UINT32_MAX;
    return listbox_get_selected(_listBox);
}

- (real32_t)rowHeight
{
    return listbox_get_row_height(_listBox);
}

- (void)onSelect:(NGListBoxSelectHandler)handler
{
    _onSelectTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        const EvButton *params = event_params(event, EvButton);
        uint32_t index = params != NULL ? params->index : UINT32_MAX;
        OFString *text = nil;
        if (params != NULL && params->text != NULL)
            text = [OFString stringWithUTF8String:(const char *)params->text];
        handler(self, index, text);
    }];
    listbox_OnSelect(_listBox, NGListenerCreate(_onSelectTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_listbox(layout, _listBox, column, row);
}

@end
