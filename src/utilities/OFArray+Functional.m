#import "OFArray+Functional.h"

@implementation OFArray(Functional)

- (instancetype)map: (id (^)(id))f
{
    return [self mappedArrayUsingBlock:^nonnil id (id object, size_t index) {
        return f(object);
    }];
}

- (instancetype)bind:(OFArray *nonnil (^nonnil)(id nonnil))f
{
    auto result = [OFMutableArray array];
    for (id item in self) {
        [result addObjectsFromArray: f(item)];
    }
    [result makeImmutable];
    return result;
}

+ (instancetype)pure: (id)value
{
    return [OFArray arrayWithObject: value];
}

- (instancetype)apply: (OFArray<id (^)(id)> *nonnil)functions
{
    auto result = [OFMutableArray array];
    for (id (^function)(id) in functions) {
        for (id item in self) {
            [result addObject: function(item)];
        }
    }
    [result makeImmutable];
    return result;
}

- (OFArray *nonnil)filter: (bool (^)(id))predicate
{
    return [self filteredArrayUsingBlock:^bool (id object, size_t index) {
        return predicate(object);
    }];
}

@end
