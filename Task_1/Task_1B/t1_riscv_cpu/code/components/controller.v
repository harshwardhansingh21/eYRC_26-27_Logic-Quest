
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump,
    output [2:0] ImmSrc,        // widened: 3 bits
    output [2:0] ALUControl,
    output       ALUSrcA,       // new: 0 = rs1, 1 = PC (auipc)
    output       Jalr           // new: next PC = ALU result with bit 0 cleared
);

wire [1:0] ALUOp;
wire       Branch;

main_decoder md (
    .op        (op),
    .ResultSrc (ResultSrc),
    .MemWrite  (MemWrite),
    .Branch    (Branch),
    .ALUSrc    (ALUSrc),
    .RegWrite  (RegWrite),
    .Jump      (Jump),
    .ImmSrc    (ImmSrc),
    .ALUOp     (ALUOp),
    .ALUSrcA   (ALUSrcA),
    .Jalr      (Jalr)
);

alu_decoder ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// for jump and branch (JALR is handled separately in the datapath)
assign PCSrc = (Branch & Zero) | Jump;

endmodule
