#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>

OF_ASSUME_NONNULL_BEGIN

typedef void (^NGEventHandler)(Event *event);

@interface NGEventListenerTarget : OFObject

@property (nonatomic, copy, readonly) NGEventHandler handler;

- (instancetype)initWithHandler:(NGEventHandler)handler;

@end

Listener *NGListenerCreate(NGEventListenerTarget *target);

OF_ASSUME_NONNULL_END
