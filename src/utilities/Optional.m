#import "Optional.h"

@implementation Optional

- (instancetype)initWithValue:(id)value
{
    self = [super init];
    _some = (value != nil);
    _data = value;
    return self;
}

- (instancetype)initNone
{
    self = [super init];
    _some = false;
    _data = nil;
    return self;
}

+ (instancetype)fromNilable:(id)value
{
    return (value != nil) ? [[self alloc] initWithValue: value] : [[self alloc] initNone];
}

+ (instancetype)some:(id)value
{
    return [[self alloc] initWithValue: $assert_nonnil(value)];
}

+ (instancetype)none
{
    return [[self alloc] initNone];
}

#pragma mark - Properties

- (bool)isSome { return _some; }
- (bool)isNone { return not _some; }

- (id)value { return _data; }

#pragma mark - Monad

+ (instancetype)pure:(id)x
{
    // “pure nil” -> none; if you want it to throw, swap to +some:
    return [self fromNilable: x];
}

- (id<Monad>)bind:(id<Monad> _Nullable (^)(id x))f
{
    if (not _some) return self;

    id<Monad> r = f(_data);
    if (r == nilptr) return [Optional none];
    return $cast(Optional, r);
}

#pragma mark - Functor

- (Optional<id> *)map:(id _Nullable (^)(id x))f
{
    if (not _some) return self;

    id y = f(_data);
    return [Optional fromNilable: y];
}

#pragma mark - Applicative

- (Optional<id> *)apply:(Optional<id _Nullable (^)(id)> *)fOpt
{
    if (not _some) return (Optional<id> *)self;
    if (fOpt == nilptr or not fOpt->_some) return [Optional none];

    return [Optional fromNilable: fOpt.value(_data)];
}

#pragma mark - Typed helper

- (Optional<id> *)andThen:(Optional<id> * _Nullable (^)(id x))f
{
    if (!_some) return (Optional<id> *)self;

    Optional<id> *r = f(_data);
    return (r != nil) ? r : [Optional none];
}

#pragma mark - Utilities

- (id)unwrap
{
    if (not _some) {
        @throw [OFInvalidArgumentException exception];
    }
    return _data;
}

- (id)unwrapOr:(id)defaultValue
{
    return _some ? _data : defaultValue;
}

- (id)orNil
{
    return _data;
}

@end
