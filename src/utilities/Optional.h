#import "common.h"
#import "Functional.h"

$assume_nonnil_begin

[[clang::objc_subclassing_restricted]]
@interface Optional<__covariant T> : OFObject<Monad> {
    @private id _data;
    @private bool _some;
}

@property(readonly) bool isSome;
@property(readonly) bool isNone;
@property(readonly, nullable) T value; // nil when none

/// Treats nil as none.
+ (instancetype)fromNilable:(T _Nullable)value [[clang::objc_direct]];

/// Requires non-nil (throws if nil). Use fromNilable: if you want nil->none.
+ (instancetype)some:(T)value [[clang::objc_direct]];

+ (instancetype)none [[clang::objc_direct]];

- (instancetype)initWithValue:(T)value [[clang::objc_direct]];
- (instancetype)initNone [[clang::objc_direct]];

#pragma mark - Functor / Applicative helpers

- (Optional *)map:(id _Nullable (^)(T x))f;
- (Optional *)apply:(Optional<id _Nullable (^)(T)> *)fOpt;

#pragma mark - Typed monad helper (recommended)

- (Optional<id> *)andThen:(Optional<id> * _Nullable (^)(T x))f;

#pragma mark - Utilities

- (T)unwrap;                 // throws if none
- (T)unwrapOr:(T)defaultValue;
- (T _Nullable)orNil;

@end

$assume_nonnil_end
