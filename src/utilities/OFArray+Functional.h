#import "common.h"
#import "Functional.h"

$assume_nonnil_begin

@interface OFArray<T>(Functional)<Monad>

- (instancetype)map: (id (^)(T x))f;
- (instancetype)bind: (OFArray *(^)(T x))f;
- (OFArray *)apply: (OFArray<id (^)(T)> *)ff;

- (instancetype)filter: (bool (^)(T x))predicate /*[[clang::objc_direct]] making this direct causes an ICE (https://github.com/llvm/llvm-project/issues/172189)*/; 

@end

$assume_nonnil_end
