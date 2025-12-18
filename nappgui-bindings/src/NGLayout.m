#import "NGLayout.h"

#import "NGButton.h"
#import "NGCombo.h"
#import "NGEdit.h"
#import "NGLabel.h"
#import "NGListBox.h"
#import "NGImageView.h"
#import "NGPopUp.h"
#import "NGProgress.h"
#import "NGSplitView.h"
#import "NGSlider.h"
#import "NGTableView.h"
#import "NGTextView.h"
#import "NGView.h"
#import "NGWebView.h"
#import "NGUpDown.h"
#import "NGLayoutItem.h"
#import <ObjFW/ObjFW.h>

@implementation NGLayout {
    Layout *_layout;
}

- (instancetype)initWithColumns:(uint32_t)columns rows:(uint32_t)rows
{
    self = [super init];
    _layout = layout_create(columns, rows);
    return self;
}

- (Layout *)handle
{
    return _layout;
}

- (void)setLabel:(NGLabel *)label column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:label column:column row:row];
}

- (void)setButton:(NGButton *)button column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:button column:column row:row];
}

- (void)setTextView:(NGTextView *)textView column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:textView column:column row:row];
}

- (void)setEdit:(NGEdit *)edit column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:edit column:column row:row];
}

- (void)setCombo:(NGCombo *)combo column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:combo column:column row:row];
}

- (void)setSlider:(NGSlider *)slider column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:slider column:column row:row];
}

- (void)setProgress:(NGProgress *)progress column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:progress column:column row:row];
}

- (void)setListBox:(NGListBox *)listBox column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:listBox column:column row:row];
}

- (void)setImageView:(NGImageView *)imageView column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:imageView column:column row:row];
}

- (void)setUpDown:(NGUpDown *)upDown column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:upDown column:column row:row];
}

- (void)setPopUp:(NGPopUp *)popUp column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:popUp column:column row:row];
}

- (void)setView:(NGView *)view column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:view column:column row:row];
}

- (void)setWebView:(NGWebView *)webView column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:webView column:column row:row];
}

- (void)setSplitView:(NGSplitView *)splitView column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:splitView column:column row:row];
}

- (void)setTableView:(NGTableView *)tableView column:(uint32_t)column row:(uint32_t)row
{
    [self setControl:tableView column:column row:row];
}

- (void)setControl:(id<NGLayoutItem>)control column:(uint32_t)column row:(uint32_t)row
{
    [control ng_placeInLayout:_layout column:column row:row];
}

- (void)setColumn:(uint32_t)column width:(real32_t)width
{
    layout_hsize(_layout, column, width);
}

- (void)setRow:(uint32_t)row height:(real32_t)height
{
    layout_vsize(_layout, row, height);
}

- (void)setMargin:(real32_t)margin
{
    layout_margin(_layout, margin);
}

- (void)setRow:(uint32_t)row margin:(real32_t)margin
{
    layout_vmargin(_layout, row, margin);
}

@end
