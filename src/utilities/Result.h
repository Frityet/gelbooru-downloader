#import "common.h"

#import "Functional.h"

$assume_nonnil_begin

[[clang::objc_subclassing_restricted]]
@interface Result<__covariant T, __covariant E> : OFObject<Monad> {
    @private id _data;
    @private bool _ok;
}

@property(readonly) T value;
@property(readonly) E error;

+ (instancetype)error:(E)error [[clang::objc_direct]];
+ (instancetype)ok:(T)value [[clang::objc_direct]];

- (instancetype)initAsError: (bool)isError value: (nillable T)value error: (nillable E)error [[clang::objc_direct]];

- (Result<id, E> *)map:(id (^)(T x))f;
- (Result<T, id> *)mapError:(id (^)(E x))f;
- (Result<id, E> *)apply:(Result<id (^)(T), E> *)rf;

@end

$assume_nonnil_end
