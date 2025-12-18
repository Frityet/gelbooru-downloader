#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>

OF_ASSUME_NONNULL_BEGIN

@interface NGControl : OFObject

@property (nonatomic) uint32_t tag;

// Subclasses must return the underlying GuiControl pointer for tag operations.
- (GuiControl *)controlHandle;

// Convenience typed handles mirroring guicontrol_* helpers
- (Label *_Nullable)labelHandle;
- (Button *_Nullable)buttonHandle;
- (PopUp *_Nullable)popUpHandle;
- (Edit *_Nullable)editHandle;
- (Combo *_Nullable)comboHandle;
- (ListBox *_Nullable)listBoxHandle;
- (UpDown *_Nullable)upDownHandle;
- (Slider *_Nullable)sliderHandle;
- (Progress *_Nullable)progressHandle;
- (View *_Nullable)viewHandle;
- (TextView *_Nullable)textViewHandle;
- (WebView *_Nullable)webViewHandle;
- (ImageView *_Nullable)imageViewHandle;
- (TableView *_Nullable)tableViewHandle;
- (SplitView *_Nullable)splitViewHandle;
- (Panel *_Nullable)panelHandle;

// Factory that wraps an existing GuiControl into an ObjFW wrapper when possible.
+ (NGControl *_Nullable)wrapControlHandle:(GuiControl *)control;

@end

OF_ASSUME_NONNULL_END
