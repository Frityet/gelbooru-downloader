#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>
#import "NGLayoutItem.h"

OF_ASSUME_NONNULL_BEGIN

@class NGButton;
@class NGLabel;
@class NGTextView;
@class NGEdit;
@class NGSlider;
@class NGProgress;
@class NGCombo;
@class NGListBox;
@class NGImageView;
@class NGUpDown;
@class NGPopUp;
@class NGView;
@class NGWebView;
@class NGSplitView;
@class NGTableView;

@interface NGLayout : OFObject

@property (nonatomic, readonly) Layout *handle;

- (instancetype)initWithColumns:(uint32_t)columns rows:(uint32_t)rows;

- (void)setLabel:(NGLabel *)label column:(uint32_t)column row:(uint32_t)row;
- (void)setButton:(NGButton *)button column:(uint32_t)column row:(uint32_t)row;
- (void)setTextView:(NGTextView *)textView column:(uint32_t)column row:(uint32_t)row;
- (void)setEdit:(NGEdit *)edit column:(uint32_t)column row:(uint32_t)row;
- (void)setCombo:(NGCombo *)combo column:(uint32_t)column row:(uint32_t)row;
- (void)setSlider:(NGSlider *)slider column:(uint32_t)column row:(uint32_t)row;
- (void)setProgress:(NGProgress *)progress column:(uint32_t)column row:(uint32_t)row;
- (void)setListBox:(NGListBox *)listBox column:(uint32_t)column row:(uint32_t)row;
- (void)setImageView:(NGImageView *)imageView column:(uint32_t)column row:(uint32_t)row;
- (void)setUpDown:(NGUpDown *)upDown column:(uint32_t)column row:(uint32_t)row;
- (void)setPopUp:(NGPopUp *)popUp column:(uint32_t)column row:(uint32_t)row;
- (void)setView:(NGView *)view column:(uint32_t)column row:(uint32_t)row;
- (void)setWebView:(NGWebView *)webView column:(uint32_t)column row:(uint32_t)row;
- (void)setSplitView:(NGSplitView *)splitView column:(uint32_t)column row:(uint32_t)row;
- (void)setTableView:(NGTableView *)tableView column:(uint32_t)column row:(uint32_t)row;

- (void)setControl:(id<NGLayoutItem>)control column:(uint32_t)column row:(uint32_t)row;

- (void)setColumn:(uint32_t)column width:(real32_t)width;
- (void)setRow:(uint32_t)row height:(real32_t)height;

- (void)setMargin:(real32_t)margin;
- (void)setRow:(uint32_t)row margin:(real32_t)margin;

@end

OF_ASSUME_NONNULL_END
