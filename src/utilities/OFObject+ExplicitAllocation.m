#import "common.h"

@implementation  OFObject (ExplicitAllocation)

+ (instancetype)allocWithAlignedBuffer:(void *)buf length:(size_t)len alignment:(size_t)align
{
    if (((uintptr_t)buf % align) != 0) {
        @throw [OFInvalidArgumentException exception];
    }
    
    auto cp = class_getInstanceSize(self);
    if (len < cp) {
        @throw [OFInvalidArgumentException exception];
    }

    return $assert_nonnil(objc_constructInstance(self, buf));
}

@end
