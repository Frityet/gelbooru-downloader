#include "Result.h"

@implementation Result

- (instancetype)initAsError:(BOOL)isError value:(id)value error:(id)error
{
    self = [super init];

    self->_ok = not isError;
    if (isError) {
        self->_data = error;
    } else {
        self->_data = value;
    }
    return self;
}


+ (instancetype)ok: (id)value
{ return [[self alloc] initAsError: false value: value error: nilptr]; }

+ (instancetype)error: (id)error
{ return [[self alloc] initAsError: true value: nilptr error: error]; }

+ (instancetype)pure: (id)x
{ return [self ok: x]; }

#pragma mark - Functor

- (instancetype)map:(id (^)(id))f
{
    if (not _ok) return self;
    return [Result ok: f(self->_data)];
}

- (instancetype)mapError:(id (^)(id))f
{
    if (_ok) return self;
    return [Result error: f(self->_data)];
}


#pragma mark - Monad

- (id<Monad>)bind:(id<Monad> (^)(id x))f
{
    if (not _ok) {
        return self;
    } else {
        return $cast(Result, f(self->_data));
    }
}

#pragma mark - Applicative

- (id)value
{ return self->_data; }

- (instancetype)apply: (Result<id (^)(id), id> *nonnil)fResult
{
    if (not _ok) return self;
    if (not fResult->_ok) return fResult;

    return [Result ok: fResult.value(self->_data)];
}

@end
