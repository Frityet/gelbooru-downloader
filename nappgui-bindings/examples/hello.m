#import <ObjFW/ObjFW.h>

#import <NAppGUIBindings.h>

$assume_nonnil_begin

@interface HelloApp : OFObject <NGApplicationDelegate> @end

@implementation HelloApp {
    NGWindow *_window;
}

- (void)applicationDidFinishLaunching:(OFNotification *)_
{
    auto app = NGApplication.sharedApplication;
    app.delegate = self;
    [app start];
}

- (void)applicationDidBecomeReady:(NGApplication *)_
{
    NGLabel *label = [[NGLabel alloc] init];
    [label setText: @"Hello from ObjFW + NAppGUI"];

    NGButton *button = [[NGButton alloc] initPush];
    [button setText:@"Quit"];
    button.tag = 42;
    [button onClick:^{
        [OFApplication terminate];
    }];

    NGTextView *text = [[NGTextView alloc] init];
    [text appendLine:@"NAppGUI is running on OFRunLoop"];
    NGControl *genericButton = [NGControl wrapControlHandle:(GuiControl *)button.handle];
    [text appendLine:[OFString stringWithFormat:@"Generic control tag: %u", genericButton.tag]];

    NGTableView *table = [[NGTableView alloc] init];
    uint32_t col = [table addTextColumn];
    [table setHeaderTitle:@"Items" forColumn:col];
    [table setHeaderClickable:true];
    [table setGridVisibleHorizontal:true vertical:true];
    [table setRowHeight:24];
    [table setColumn:col alignment:ekLEFT];
    [table setColumn:col resizable:true];
    [table setRowCountProvider:^uint32_t{
        return 5;
    }];
    [table setCellProvider:^NGTableCell(uint32_t row, uint32_t column) {
        unref(column);
        return (NGTableCell){
            .text = [OFString stringWithFormat:@"Row %u", row],
            .icon = NULL,
            .align = ekLEFT
        };
    }];
    [table onSelectionChanged:^(OFArray<OFNumber *> *rows) {
        [text appendLine:[OFString stringWithFormat:@"Selected rows: %@", rows]];
    }];

    NGLayout *layout = [[NGLayout alloc] initWithColumns:1 rows:4];
    [layout setLabel:label column:0 row:0];
    [layout setButton:button column:0 row:1];
    [layout setTextView:text column:0 row:2];
    [layout setTableView:table column:0 row:3];
    [layout setColumn:0 width:260];
    [layout setRow:2 height:120];
    [layout setRow:3 height:140];
    [layout setMargin:6];
    [layout setRow:0 margin:6];
    [layout setRow:1 margin:6];
    [layout setRow:3 margin:6];

    NGPanel *panel = [[NGPanel alloc] init];
    [panel setLayout: layout];

    _window = [[NGWindow alloc] initWithFlags: ekWINDOW_STD];
    // [_window setPanel: panel];
    // [_window setTitle: @"nappgui-bindings-hello"];
    // [_window setOrigin: v2df(200, 200)];
    _window.panel = panel;
    _window.title = @"nappgui-bindings-hello";
    _window.origin = v2df(200, 200);
    [_window onClose: ^{
        [OFApplication terminate];
    }];
    [_window show];
}

- (void)applicationWillTerminate:(OFNotification *)notification
{
    unref(notification);

    [NGApplication.sharedApplication stop];
    _window = nil;
}

@end

$assume_nonnil_end

OF_APPLICATION_DELEGATE(HelloApp);
