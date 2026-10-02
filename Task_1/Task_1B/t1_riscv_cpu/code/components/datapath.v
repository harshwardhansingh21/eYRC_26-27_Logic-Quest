
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [2:0]   ImmSrc,          // widened: 3 bits
    input [2:0]   ALUControl,
    input         ALUSrcA,         // new: 0 = rs1, 1 = PC (auipc)
    input         Jalr,            // new: jalr overrides next PC
    output        Zero,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCNextBase, PCPlus4, PCTarget;
wire [31:0] ImmExt, RD1, SrcA, SrcB, WriteData, ALUResult;

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNextBase);   // was PCNext

// jalr: target = (rs1 + imm) with bit 0 cleared
assign PCNext = Jalr ? (ALUResult & 32'hFFFF_FFFE) : PCNextBase;

// register file logic (rs1 data is now RD1, not SrcA)
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, RD1, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcamux(RD1, PC, ALUSrcA, SrcA);               // new: PC for auipc
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, Zero);

// result mux: 00 = ALU, 01 = memory, 10 = PC+4, 11 = immediate (lui)
mux4 #(32)     resultmux(ALUResult, ReadData, PCPlus4, ImmExt, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule
