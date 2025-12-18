#pragma once

#import <ObjFW/ObjFW.h>
#include <nappgui.h>

OF_ASSUME_NONNULL_BEGIN

@protocol NGLayoutItem <OFObject>
- (void)ng_placeInLayout:(Layout *)layout column:(uint32_t)column row:(uint32_t)row;
@end

OF_ASSUME_NONNULL_END
