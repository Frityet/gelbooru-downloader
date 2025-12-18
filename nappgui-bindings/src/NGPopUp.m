#import "NGPopUp.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGPopUp {
    PopUp *_popUp;
    NGEventListenerTarget *_onSelectTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_popUp;
}

- (instancetype)initWithExistingHandle:(PopUp *)handle
{
    self = [super init];
    _popUp = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _popUp = popup_create();
    return self;
}

- (PopUp *)handle
{
    return _popUp;
}

- (void)setTooltip:(OFString *_Nullable)text
{
    const char *raw = text != nil ? text.UTF8String : NULL;
    popup_tooltip(_popUp, raw);
}

- (void)addItem:(OFString *)text
{
    popup_add_elem(_popUp, text.UTF8String, NULL);
}

- (void)setItem:(OFString *)text atIndex:(uint32_t)index
{
    popup_set_elem(_popUp, index, text.UTF8String, NULL);
}

- (void)insertItem:(OFString *)text atIndex:(uint32_t)index
{
    popup_ins_elem(_popUp, index, text.UTF8String, NULL);
}

- (void)removeItemAtIndex:(uint32_t)index
{
    popup_del_elem(_popUp, index);
}

- (void)clear
{
    popup_clear(_popUp);
}

- (uint32_t)count
{
    return popup_count(_popUp);
}

- (void)setListHeight:(uint32_t)items
{
    popup_list_height(_popUp, items);
}

- (void)selectIndex:(uint32_t)index
{
    popup_selected(_popUp, index);
}

- (uint32_t)selectedIndex
{
    return popup_get_selected(_popUp);
}

- (OFString *)itemTextAtIndex:(uint32_t)index
{
    const char_t *raw = popup_get_text(_popUp, index);
    return [OFString stringWithUTF8String:(const char *)raw];
}

- (void)onSelect:(NGPopUpSelectHandler)handler
{
    _onSelectTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        const EvButton *params = event_params(event, EvButton);
        uint32_t index = params != NULL ? params->index : UINT32_MAX;
        OFString *text = nil;
        if (params != NULL && params->text != NULL)
            text = [OFString stringWithUTF8String:(const char *)params->text];
        handler(self, index, text);
    }];
    popup_OnSelect(_popUp, NGListenerCreate(_onSelectTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_popup(layout, _popUp, column, row);
}

@end
