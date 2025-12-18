#import "common.h"

@interface OFObject (ExplicitAllocation)

+ (instancetype)allocWithAlignedBuffer: (void *)buf length: (size_t)len alignment: (size_t)align;

@end
