#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>

OF_ASSUME_NONNULL_BEGIN

@protocol NGApplicationDelegate;

@interface NGApplication : OFObject

@property (class, readonly, nonatomic) NGApplication *sharedApplication;

@property (nonatomic, weak, nullable) id<NGApplicationDelegate> delegate;

@property (nonatomic) OFTimeInterval pollInterval;
@property (nonatomic) real64_t transitionInterval;

@property (readonly, nonatomic, getter=isReady) bool ready;

- (void)start;
- (void)stop;

- (void)whenReady:(void (^)(void))handler;

@end

@protocol NGApplicationDelegate <OFApplicationDelegate>
@optional
- (void)applicationDidBecomeReady:(NGApplication *)application;
@end

OF_ASSUME_NONNULL_END
