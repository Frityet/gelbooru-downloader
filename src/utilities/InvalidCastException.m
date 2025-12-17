#import "common.h"

@implementation InvalidCastException

- (instancetype)initFromType:(Class)fromType toType:(Class)toType {
    self = [super init];
    _fromType = fromType;
    _toType = toType;
    return self;
}

+ (instancetype)exceptionFromType:(Class)fromType toType:(Class)toType
{ return [[self alloc] initFromType:fromType toType:toType]; }

- (OFString *)description {
    return [OFString stringWithFormat: @"InvalidCastException: Cannot cast from type %@ to type %@", _fromType, _toType];
}

@end
