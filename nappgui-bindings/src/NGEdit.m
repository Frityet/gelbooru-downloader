#import "NGEdit.h"

#import "NGEventListenerTarget.h"
#import "NGLayoutItem.h"

@implementation NGEdit {
    Edit *_edit;
    NGEventListenerTarget *_onChangeTarget;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_edit;
}

- (instancetype)initWithExistingHandle:(Edit *)handle
{
    self = [super init];
    _edit = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _edit = edit_create();
    return self;
}

- (instancetype)initMultiline
{
    self = [super init];
    _edit = edit_multiline();
    return self;
}

- (Edit *)handle
{
    return _edit;
}

- (void)setText:(OFString *)text
{
    edit_text(_edit, text.UTF8String);
}

- (OFString *)text
{
    const char_t *raw = edit_get_text(_edit);
    return [OFString stringWithUTF8String:(const char *)raw];
}

- (void)setPlaceholder:(OFString *)text
{
    edit_phtext(_edit, text.UTF8String);
}

- (void)setEditable:(bool)editable
{
    edit_editable(_edit, editable);
}

- (void)setPasswordMode:(bool)enabled
{
    edit_passmode(_edit, enabled);
}

- (void)onChange:(NGEditChangeHandler)handler
{
    _onChangeTarget = [[NGEventListenerTarget alloc] initWithHandler:^(Event *event) {
        unref(event);
        handler(self, self.text);
    }];
    edit_OnChange(_edit, NGListenerCreate(_onChangeTarget));
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_edit(layout, _edit, column, row);
}

@end
