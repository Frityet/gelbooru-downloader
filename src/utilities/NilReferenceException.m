#import "common.h"

@implementation NilReferenceException

- (instancetype)initWithExpression:(OFConstantString *)expression
{
    self = [super init];
    self->_expression = expression;
    return self;
}

+ (instancetype)exceptionWithExpression:(OFConstantString *)expression
{ return [[self alloc] initWithExpression: expression]; }

- (OFString *)description
{
    return [OFString stringWithFormat:@"Nil reference exception: %@ == nilptr", self->_expression];
}

@end
