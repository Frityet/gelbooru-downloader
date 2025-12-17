#import "common.h"

$assume_nonnil_begin


@protocol Functor<OFObject>
/// fmap :: (a -> b) -> f a -> f b
- (id)map:(id (^)(id x))f;
@end

@protocol Applicative <Functor>
/// pure :: a -> f a   (best modeled as a class method)
+ (instancetype)pure:(id)x;

/// ap / (<*>) :: f (a -> b) -> f a -> f b
- (id)apply:(id<Applicative>)fa;
@end

@protocol Monad <Applicative>
/// bind / (>>=) :: m a -> (a -> m b) -> m b
- (id)bind:(id<Monad> (^)(id x))f;
@end

$assume_nonnil_end
