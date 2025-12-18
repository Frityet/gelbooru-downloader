#import "NGCombo.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGCombo {
    Combo *_combo;
    NGEventListenerTarget *_onSelectTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_combo;
}

- (instancetype)initWithExistingHandle:(Combo *)handle
{
    self = [super init];
    _combo = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _combo = combo_create();
    return self;
}

- (Combo *)handle
{
    return _combo;
}

- (void)setText:(OFString *)text
{
    combo_text(_combo, text.UTF8String);
}

- (OFString *)text
{
    const char_t *raw = combo_get_text(_combo, combo_get_selected(_combo));
    return [OFString stringWithUTF8String:(const char *)raw];
}

- (void)addItem:(OFString *)text
{
    combo_add_elem(_combo, text.UTF8String, NULL);
}

- (void)setItem:(OFString *)text atIndex:(uint32_t)index
{
    combo_set_elem(_combo, index, text.UTF8String, NULL);
}

- (void)insertItem:(OFString *)text atIndex:(uint32_t)index
{
    combo_ins_elem(_combo, index, text.UTF8String, NULL);
}

- (void)removeItemAtIndex:(uint32_t)index
{
    combo_del_elem(_combo, index);
}

- (void)clear
{
    combo_clear(_combo);
}

- (uint32_t)count
{
    return combo_count(_combo);
}

- (void)selectIndex:(uint32_t)index
{
    combo_selected(_combo, index);
}

- (uint32_t)selectedIndex
{
    return combo_get_selected(_combo);
}

- (OFString *)itemTextAtIndex:(uint32_t)index
{
    const char_t *raw = combo_get_text(_combo, index);
    return [OFString stringWithUTF8String:(const char *)raw];
}

- (void)onSelect:(NGComboSelectHandler)handler
{
    _onSelectTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler(self, self.selectedIndex);
    }];
    combo_OnSelect(_combo, NGListenerCreate(_onSelectTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_combo(layout, _combo, column, row);
}

@end
