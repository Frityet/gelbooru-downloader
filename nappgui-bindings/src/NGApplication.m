#import "NGApplication.h"

#include <core/clock.h>
#include <draw2d/guictx.h>
#include <osgui/osgui.h>
#include <osgui/osguictx.h>

#if defined(__LINUX__)
#include <gtk/gtk.h>
#include <locale.h>
#include <stdlib.h>
#endif

@interface NGApplication ()
#if defined(__LINUX__)
- (void)of_onGtkActivate:(GtkApplication *)gtkApp;
#endif
- (void)of_pumpOnce;
@end

#if defined(__LINUX__)
static void NGOnGtkActivate(GtkApplication *gtkApp, gpointer userData)
{
    NGApplication *app = (__bridge NGApplication *)userData;
    [app of_onGtkActivate:gtkApp];
}
#endif

static NGApplication *gSharedApplication = nil;

static void NGInitSharedApplication(void)
{
    gSharedApplication = [[NGApplication alloc] init];
}

@implementation NGApplication {
    bool _started;
    bool _ready;

    OFTimeInterval _pollInterval;
    real64_t _transitionInterval;

    __weak id<NGApplicationDelegate> _delegate;

    OFTimer *_pollTimer;
    OFMutableArray<void (^)(void)> *_readyHandlers;

    GuiCtx *_nativeGui;
    Clock *_transitionClock;

#if defined(__LINUX__)
    GtkApplication *_gtkApp;
    bool _gtkHeld;
#endif
}

+ (NGApplication *)sharedApplication
{
    static OFOnceControl once = OFOnceControlInitValue;
    OFOnce(&once, NGInitSharedApplication);
    return gSharedApplication;
}

- (instancetype)init
{
    self = [super init];
    _started = false;
    _ready = false;
    _pollInterval = 0.01;
    _transitionInterval = 0.02;
    _delegate = nil;
    _readyHandlers = [[OFMutableArray alloc] init];
    _nativeGui = NULL;
    _transitionClock = NULL;

#if defined(__LINUX__)
    _gtkApp = NULL;
    _gtkHeld = false;
#endif

    return self;
}

- (id<NGApplicationDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<NGApplicationDelegate>)delegate
{
    _delegate = delegate;
}

- (OFTimeInterval)pollInterval
{
    return _pollInterval;
}

- (void)setPollInterval:(OFTimeInterval)pollInterval
{
    _pollInterval = pollInterval;
}

- (real64_t)transitionInterval
{
    return _transitionInterval;
}

- (void)setTransitionInterval:(real64_t)transitionInterval
{
    _transitionInterval = transitionInterval;
}

- (bool)isReady
{
    return _ready;
}

- (void)whenReady:(void (^)(void))handler
{
    if (_ready) {
        handler();
        return;
    }

    [_readyHandlers addObject:[handler copy]];
}

- (void)start
{
    if (_started)
        return;

    _started = true;
    _ready = false;

    osgui_start();
    gui_start();

    _nativeGui = osguictx();
    guictx_set_current(_nativeGui);

    _transitionClock = clock_create(_transitionInterval);

#if defined(__LINUX__)
    static char GDK_BACKEND[] = "GDK_BACKEND=x11";
    putenv(GDK_BACKEND);

    _gtkApp = gtk_application_new("com.nappgui.app", G_APPLICATION_NON_UNIQUE);
    if (_gtkApp == NULL)
        @throw [OFInitializationFailedException exceptionWithClass:[self class]];

    g_signal_connect(_gtkApp, "activate", G_CALLBACK(NGOnGtkActivate), (__bridge gpointer)self);

    GError *error = NULL;
    if (g_application_register(G_APPLICATION(_gtkApp), NULL, &error) == FALSE) {
        if (error != NULL)
            g_error_free(error);
        @throw [OFInitializationFailedException exceptionWithClass:[self class]];
    }

    g_application_activate(G_APPLICATION(_gtkApp));
#endif

    __unsafe_unretained NGApplication *unretainedSelf = self;
    _pollTimer = [OFTimer scheduledTimerWithTimeInterval:_pollInterval
                                                repeats:true
                                                  block:^(OFTimer *timer) {
        unref(timer);
        [unretainedSelf of_pumpOnce];
    }];
}

- (void)stop
{
    if (!_started)
        return;

    [_pollTimer invalidate];
    _pollTimer = nil;

#if defined(__LINUX__)
    if (_gtkApp != NULL) {
        if (_gtkHeld) {
            g_application_release(G_APPLICATION(_gtkApp));
            _gtkHeld = false;
        }

        g_application_quit(G_APPLICATION(_gtkApp));
        g_object_unref(_gtkApp);
        _gtkApp = NULL;
    }
#endif

    if (_transitionClock != NULL)
        clock_destroy(&_transitionClock);

    if (_nativeGui != NULL)
        guictx_destroy(&_nativeGui);

    gui_finish();
    osgui_finish();

    _ready = false;
    _started = false;
    [_readyHandlers removeAllObjects];
}

#if defined(__LINUX__)
- (void)of_onGtkActivate:(GtkApplication *)gtkApp
{
    unref(gtkApp);

    if (_gtkHeld)
        return;

    setlocale(LC_NUMERIC, "C");

    osgui_set_app(_gtkApp, NULL);
    osgui_initialize();

    g_application_hold(G_APPLICATION(_gtkApp));
    _gtkHeld = true;
}
#endif

- (void)of_pumpOnce
{
#if defined(__LINUX__)
    while (g_main_context_iteration(NULL, FALSE))
        ;
#endif

    if (!_ready && osgui_is_initialized() == TRUE) {
        _ready = true;
        gui_update();

        if (_delegate != nil && [_delegate respondsToSelector:@selector(applicationDidBecomeReady:)])
            [_delegate applicationDidBecomeReady:self];

        for (void (^handler)(void) in _readyHandlers)
            handler();

        [_readyHandlers removeAllObjects];
    }

    if (_transitionClock != NULL) {
        real64_t prev, curr;
        if (clock_frame(_transitionClock, &prev, &curr))
            gui_update_transitions(prev, curr);
    }
}

@end
