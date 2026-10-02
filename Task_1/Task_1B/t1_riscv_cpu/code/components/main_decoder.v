
// main_decoder.v - logic for main decoder

module main_decoder (
    input  [6:0] op,
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump,
    output [2:0] ImmSrc,      // widened: 3 bits
    output [1:0] ALUOp,
    output       ALUSrcA,     // new: 0 = rs1, 1 = PC
    output       Jalr         // new: next PC comes from the ALU result
);

reg [13:0] controls;

always @(*) begin
    case (op)
        // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump_ALUSrcA_Jalr
        7'b0000011: controls = 14'b1_000_1_0_01_0_00_0_0_0; // lw
        7'b0100011: controls = 14'b0_001_1_1_00_0_00_0_0_0; // sw
        7'b0110011: controls = 14'b1_000_0_0_00_0_10_0_0_0; // R-type
        7'b1100011: controls = 14'b0_010_0_0_00_1_01_0_0_0; // beq
        7'b0010011: controls = 14'b1_000_1_0_00_0_10_0_0_0; // I-type ALU
        7'b1101111: controls = 14'b1_011_0_0_10_0_00_1_0_0; // jal
        7'b0110111: controls = 14'b1_100_1_0_11_0_00_0_0_0; // lui   (result = ImmExt)
        7'b0010111: controls = 14'b1_100_1_0_00_0_00_0_1_0; // auipc (PC + ImmExt via ALU add)
        7'b1100111: controls = 14'b1_000_1_0_10_0_00_0_0_1; // jalr  (rs1 + I-imm, rd = PC+4)
        default:    controls = 14'b0;                       // safe default: no writes, no jumps
    endcase
end

assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump, ALUSrcA, Jalr} = controls;

endmodule
