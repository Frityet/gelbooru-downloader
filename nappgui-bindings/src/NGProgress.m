#import "NGProgress.h"
#import "NGLayoutItem.h"

@implementation NGProgress {
    Progress *_progress;
}

- (GuiControl *)controlHandle
{
    return (GuiControl *)_progress;
}

- (instancetype)initWithExistingHandle:(Progress *)handle
{
    self = [super init];
    _progress = handle;
    return self;
}

- (instancetype)init
{
    self = [super init];
    _progress = progress_create();
    return self;
}

- (Progress *)handle
{
    return _progress;
}

- (void)setIndeterminate:(bool)running
{
    progress_undefined(_progress, running);
}

- (void)setValue:(real32_t)value
{
    progress_value(_progress, value);
}

- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row
{
    layout_progress(layout, _progress, column, row);
}

@end
