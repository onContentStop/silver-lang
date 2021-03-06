import chunktypes
import chunk
import io
import ptr_arithmetic
import value

proc disassemble*(self: Chunk, name: cstring)
proc disassembleInstruction*(self: Chunk, offset: int): int
proc simpleInstruction(name: cstring, offset: int): int
proc constantInstruction(name: OpCode, self: Chunk, offset: int): int

proc disassemble*(self: Chunk, name: cstring) =
    printf("== %s ==\n", name)

    var offset = 0
    while offset < self.count:
        offset = disassembleInstruction(self, offset)

proc disassembleInstruction*(self: Chunk, offset: int): int =
    printf("%04d ", offset)
    let currLine = self.getLine(offset)
    if offset > 0 and currLine == self.getLine(offset - 1):
        printf("   | ")
    else:
        printf("%4d ", currLine)

    let instruction = (self.code + offset)[]
    case instruction:
        of opConstant.uint8:
            return constantInstruction(opConstant, self, offset)
        of opConstantLong.uint8:
            return constantInstruction(opConstantLong, self, offset)
        of opNull.uint8:
            return simpleInstruction("opNull", offset)
        of opTrue.uint8:
            return simpleInstruction("opTrue", offset)
        of opFalse.uint8:
            return simpleInstruction("opFalse", offset)
        of opEqual.uint8:
            return simpleInstruction("opEqual", offset)
        of opGreater.uint8:
            return simpleInstruction("opGreater", offset)
        of opLess.uint8:
            return simpleInstruction("opLess", offset)
        of opAdd.uint8:
            return simpleInstruction("opAdd", offset)
        of opSubtract.uint8:
            return simpleInstruction("opSubtract", offset)
        of opMultiply.uint8:
            return simpleInstruction("opMultiply", offset)
        of opDivide.uint8:
            return simpleInstruction("opDivide", offset)
        of opNot.uint8:
            return simpleInstruction("opNot", offset)
        of opNegate.uint8:
            return simpleInstruction("opNegate", offset)
        of opPrint.uint8:
            return simpleInstruction("opPrint", offset)
        of opReturn.uint8:
            return simpleInstruction("opReturn", offset)
        else:
            printf("Unknown opcode %d\n", instruction)
            return offset + 1

proc simpleInstruction(name: cstring, offset: int): int =
    printf("%s\n", name)
    return offset + 1

proc constantInstruction(name: OpCode, self: Chunk, offset: int): int =
    var constant: uint
    if name == opConstantLong:
        printf("%-16s", "opConstantLong")
        let hi = (self.code + offset + 1)[]
        let mid = (self.code + offset + 2)[]
        let lo = (self.code + offset + 3)[]
        constant = (hi.uint shl 8) + (mid.uint shl 4) + lo.uint
        result = offset + 4
    else:
        printf("%-16s", "opConstant")
        constant = (self.code + offset + 1)[].uint
        result = offset + 2
    printf(" %4d '", constant)
    (self.constants.values + constant)[].print()
    printf("'\n")
