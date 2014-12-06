# Generates block dispatch stubs up to a specified maximum number of arguments

maxArgs = ARGV[0].to_i

source = "// This file was autogenerated so don't modify it.
// (Compiled with support for up to #{maxArgs} arguments)

\#import <Tranquil/Shared/TQDebug.h>
\#import <Tranquil/Runtime/TQRuntime.h>
\#import <Tranquil/Runtime/TQRuntimePrivate.h>
\#import <objc/runtime.h>
\#import \"TQStubs.h\"
// Passing the sentinel represents that no argument was passed for that slot
\#define TQN TQNothing

#ifdef __cplusplus
extern \"C\" {
#endif

id (*TQBlockDispatchers[])(id, ...) = {
"
(0..maxArgs).each { |i| source << "    (id (*)(id, ...))&TQDispatchBlock#{i},\n" }
source <<"
};
"

(0..maxArgs).each do |i|
    source << "id TQDispatchBlock#{i}(id blockObj"; (1..i).each { |j| source << ", id a#{j}" }; source << ")
{
    struct TQBlockLiteral *block = (struct TQBlockLiteral *)blockObj;
    static void *underflowJmpTbl[] = { "
    (i..maxArgs).each { |j| source << "&&underflow#{j-i}"; source << ", " unless j == maxArgs }; source << " };\n"
    source << "
    if(__builtin_expect(!block, 0))
        TQAssert(NO, @\"Tried to call nil.\");
    else if(__builtin_expect(!((uintptr_t)block & 0x1) && block->flags & TQ_BLOCK_IS_TRANQUIL_BLOCK, 1)) {
        if(block->descriptor->numArgs > #{maxArgs})
            TQAssert(NO, @\"Tranquil was compiled with support for #{maxArgs} block arguments. You tried to call a block that takes %d.\", block->descriptor->numArgs);
        else if(block->descriptor->isVariadic) {
            if(block->descriptor->numArgs <= #{i})
                goto *underflowJmpTbl[0];
            else
                goto *underflowJmpTbl[block->descriptor->numArgs"; source << " - #{i}" unless i == 0; source <<"];
        } else {
            if(block->descriptor->numArgs == #{i})
                return block->invoke(block"; (1..i).each { |j| source << ", a#{j}"; }; source << ");
            else if(block->descriptor->numArgs > #{i})
                goto *underflowJmpTbl[block->descriptor->numArgs"; source << "- #{i+1}" unless i == 0; source <<"];
            else if(block->descriptor->numArgs < #{i})
                TQAssert(NO, @\"Too many arguments to %@! #{i} for %d\", block, block->descriptor->numArgs);
        }
    } else { // Foreign block -> no validation possible
        TQAssert([(id)block isKindOfClass:objc_getClass(\"NSBlock\")], @\"Tried to call a non-block object.\");

        return block->invoke(block"; (1..i).each { |j| source << ", a#{j}"; }; source << ");
    }
"
    (i..maxArgs).each do |j|
    source << "    underflow#{j-i}:\n"
    source << "        return block->invoke(block";
        (1..i).each { |k| source << ", a#{k}" };
        (i..j).each { |k| source << ", TQN"; }; source << ");\n"
    end
    source << "}\n\n"
end

# Create a NSBlock category for calling the block as well
source << "
    @implementation NSBlock (TQStubs)"
(0..maxArgs).each { |i|
    source << "
    - (id)call#{ (0...i).reduce("") {|s, n| s << ":(id)a#{n} "} }
    {
        return TQDispatchBlock#{i}(self#{(0...i).reduce("") {|s, n| s<<", a#{n}"} });
    }"
}
source << "
    - (id)callWithArguments:(NSArray *)aArguments
    {
        // We also want to work with NSPointerArray which doesn't implement -getObjects:
        unsigned long count = [aArguments count];
        id args[count * sizeof(id)];
        NSUInteger c;
        NSUInteger i = 0;
        NSFastEnumerationState enumState = {0};
        while((c = [aArguments countByEnumeratingWithState:&enumState
                                                   objects:NULL
                                                     count:0]) != 0) {
            memcpy(args+ i*sizeof(id), enumState.itemsPtr, c*sizeof(id));
            i += c;
        }
        switch(count) {"
            (0..maxArgs).each { |i|
                source << "
                case #{i}:
                    return TQDispatchBlock#{i}(self#{(0...i).reduce("") {|s, n| s<<", args[#{n}]"} });"
            }
        source << "
            default:
                return nil;
        }
    }
    @end

#undef TQN
#ifdef __cplusplus
}
#endif\n"
print source
