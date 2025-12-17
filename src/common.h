#pragma once

#import <ObjFW/ObjFW.h>
#import <iso646.h>

#define nillable _Nullable
#define nonnil _Nonnull
#define noescape [[clang::noescape]]
#define strong __strong
#define weak __weak
#define unretained __unsafe_unretained
#define blockref __block

#define $assume_nonnil_begin OF_ASSUME_NONNULL_BEGIN
#define $assume_nonnil_end OF_ASSUME_NONNULL_END


constexpr id nillable nilptr = nullptr;

@interface NilReferenceException : OFException

@property(readonly, nonatomic, nonnull) OFString *expression;

- (instancetype)initWithExpression:(OFConstantString *nonnil)expression;
+ (instancetype)exceptionWithExpression:(OFConstantString *nonnil)expression;

@end

@interface InvalidCastException : OFException
@property(readonly, nonatomic, nonnull) Class fromType;
@property(readonly, nonatomic, nonnull) Class toType;

- (instancetype)initFromType: (Class nonnil)fromType toType: (Class nonnil)toType;
+ (instancetype)exceptionFromType: (Class nonnil)fromType toType: (Class nonnil)toType;
@end

#define $assert_nonnil(...) ({ \
    auto nn = (__VA_ARGS__); \
    if (not nn) { \
        @throw [NilReferenceException exceptionWithExpression:@#__VA_ARGS__]; \
    } \
    (typeof(typeof(*(__VA_ARGS__)) *nonnil))nn; \
})

#define $cast(ty, val) ({ \
    id v = $assert_nonnil(val); \
    if (not [v isKindOfClass: [ty class]]) { \
        @throw [InvalidCastException exceptionFromType: [v class] toType: [ty class]]; \
    } \
    (typeof(typeof(ty) *nonnil))v; \
})
