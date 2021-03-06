// The root class of Tranquil which classes created using Tranquil inherit from by default
// Subclasses of TQObject should never accept or return anything but objects from their methods

// Boolean methods on TQObject and it's subclasses return nil on failure and TQValid on success

#import <Foundation/Foundation.h>

@class TQNumber;

@interface TQObject : NSObject
+ (Class)metaClass;

+ (id)addMethod:(NSString *)aSel withBlock:(id)aBlock replaceExisting:(id)shouldReplace;
+ (id)addMethod:(NSString *)aSel withBlock:(id)aBlock;
+ (id)initializer:(NSArray *)aProperties;
+ (id)accessor:(NSString *)aPropName initialValue:(id<NSCopying>)aInitial;
+ (id)accessor:(NSString *)aPropName;
+ (id)accessors:(id)aAccessors;
+ (id)reader:(NSString *)aPropName initialValue:(id<NSCopying>)aInitial;
+ (id)reader:(NSString *)aPropName;
+ (id)readers:(id)aAccessors;
+ (NSArray *)classMethods;
+ (NSArray *)instanceMethods;
- (NSArray *)methods;
- (id)respondsTo:(NSString *)aSelector;
- (id)isa:(Class)aClass;
- (id)isNil;
- (id)isIdenticalTo:(id)obj;
- (id)isEqualTo:(id)b;
- (id)notEqualTo:(id)b;
- (id)isLesserThan:(id)b;
- (id)isGreaterThan:(id)b;
- (id)isLesserOrEqualTo:(id)b;
- (id)isGreaterOrEqualTo:(id)b;

- (id)case:(id)aCases;
- (id)case:(id)aCases default:(id (^)())aDefaultCase;

- (id)perform:(NSString *)aSelector withArguments:(NSArray *)aArguments;
- (id)perform:(NSString *)aSelector;
- (id)perform:(NSString *)aSelector :(id)a1;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6 :(id)a7;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6 :(id)a7 :(id)a8;
- (id)perform:(NSString *)aSelector :(id)a1 :(id)a2 :(id)a3 :(id)a4 :(id)a5 :(id)a6 :(id)a7 :(id)a8 :(id)a9;
@end
