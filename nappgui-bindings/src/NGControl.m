#import "NGControl.h"
#import "NGButton.h"
#import "NGCombo.h"
#import "NGEdit.h"
#import "NGImageView.h"
#import "NGLabel.h"
#import "NGListBox.h"
#import "NGPanel.h"
#import "NGPopUp.h"
#import "NGProgress.h"
#import "NGSlider.h"
#import "NGSplitView.h"
#import "NGTextView.h"
#import "NGUpDown.h"
#import "NGTableView.h"
#import "NGView.h"
#import "NGWebView.h"
// NGTableView binding (minimal) declared below.

@implementation NGControl

- (GuiControl *)controlHandle
{
    @throw [OFNotImplementedException exceptionWithSelector:_cmd object:self];
}

- (uint32_t)tag
{
    return guicontrol_get_tag(self.controlHandle);
}

- (void)setTag:(uint32_t)tag
{
    guicontrol_tag(self.controlHandle, tag);
}

- (Label *)labelHandle { return guicontrol_label(self.controlHandle); }
- (Button *)buttonHandle { return guicontrol_button(self.controlHandle); }
- (PopUp *)popUpHandle { return guicontrol_popup(self.controlHandle); }
- (Edit *)editHandle { return guicontrol_edit(self.controlHandle); }
- (Combo *)comboHandle { return guicontrol_combo(self.controlHandle); }
- (ListBox *)listBoxHandle { return guicontrol_listbox(self.controlHandle); }
- (UpDown *)upDownHandle { return guicontrol_updown(self.controlHandle); }
- (Slider *)sliderHandle { return guicontrol_slider(self.controlHandle); }
- (Progress *)progressHandle { return guicontrol_progress(self.controlHandle); }
- (View *)viewHandle { return guicontrol_view(self.controlHandle); }
- (TextView *)textViewHandle { return guicontrol_textview(self.controlHandle); }
- (WebView *)webViewHandle { return guicontrol_webview(self.controlHandle); }
- (ImageView *)imageViewHandle { return guicontrol_imageview(self.controlHandle); }
- (TableView *)tableViewHandle { return guicontrol_tableview(self.controlHandle); }
- (SplitView *)splitViewHandle { return guicontrol_splitview(self.controlHandle); }
- (Panel *)panelHandle { return guicontrol_panel(self.controlHandle); }

+ (NGControl *)wrapControlHandle:(GuiControl *)control
{
    if (control == NULL)
        return nil;

    Label *label = guicontrol_label(control);
    if (label != NULL)
        return [[NGLabel alloc] initWithExistingHandle:label];

    Button *button = guicontrol_button(control);
    if (button != NULL)
        return [[NGButton alloc] initWithExistingHandle:button];

    PopUp *popUp = guicontrol_popup(control);
    if (popUp != NULL)
        return [[NGPopUp alloc] initWithExistingHandle:popUp];

    Edit *edit = guicontrol_edit(control);
    if (edit != NULL)
        return [[NGEdit alloc] initWithExistingHandle:edit];

    Combo *combo = guicontrol_combo(control);
    if (combo != NULL)
        return [[NGCombo alloc] initWithExistingHandle:combo];

    ListBox *listBox = guicontrol_listbox(control);
    if (listBox != NULL)
        return [[NGListBox alloc] initWithExistingHandle:listBox];

    UpDown *upDown = guicontrol_updown(control);
    if (upDown != NULL)
        return [[NGUpDown alloc] initWithExistingHandle:upDown];

    Slider *slider = guicontrol_slider(control);
    if (slider != NULL)
        return [[NGSlider alloc] initWithExistingHandle:slider];

    Progress *progress = guicontrol_progress(control);
    if (progress != NULL)
        return [[NGProgress alloc] initWithExistingHandle:progress];

    TextView *textView = guicontrol_textview(control);
    if (textView != NULL)
        return [[NGTextView alloc] initWithExistingHandle:textView];

    WebView *webView = guicontrol_webview(control);
    if (webView != NULL)
        return [[NGWebView alloc] initWithExistingHandle:webView];

    ImageView *imageView = guicontrol_imageview(control);
    if (imageView != NULL)
        return [[NGImageView alloc] initWithExistingHandle:imageView];

    TableView *tableView = guicontrol_tableview(control);
    if (tableView != NULL)
        return [[NGTableView alloc] initWithExistingHandle:tableView];

    SplitView *splitView = guicontrol_splitview(control);
    if (splitView != NULL)
        return [[NGSplitView alloc] initWithExistingHandle:splitView];

    View *view = guicontrol_view(control);
    if (view != NULL)
        return [[NGView alloc] initWithExistingHandle:view];

    Panel *panel = guicontrol_panel(control);
    if (panel != NULL)
        return [[NGPanel alloc] initWithExistingHandle:panel];

    return nil;
}

@end
