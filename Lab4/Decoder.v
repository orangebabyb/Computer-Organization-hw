// ID
module Decoder( 
	instr_op_i, 
	ALUOp_o, 
	ALUSrc_o,
	RegWrite_o,	
	RegDst_o,
	Branch_o,
	MemRead_o, 
	MemWrite_o, 
	MemtoReg_o
);
     
// TO DO
input  [5:0] instr_op_i;
output [1:0] ALUOp_o;
output       ALUSrc_o;
output       RegWrite_o;
output [1:0] RegDst_o;    // 00: rt, 01: rd
output [1:0] Branch_o;     // 01: beq, 10: bne
output       MemRead_o;
output       MemWrite_o;
output       MemtoReg_o;    // 00: ALU, 01: DMEM

//TODO
reg [1:0] ALUop;
reg ALUSrc, RegWrite, MemRead, MemWrite;
reg [1:0] RegDst, Branch, MemtoReg;

localparam [5:0] //funct field
  R_type = 6'b000000, 
  ADDI   = 6'b001001, 
  LW     = 6'b101100, 
  SW     = 6'b100100, 
  BEQ    = 6'b000110, 
  BNE    = 6'b000101; 

always @(*) begin
    ALUop     = 2'b00;
    ALUSrc    = 1'b0;
    RegWrite  = 1'b0;
    RegDst    = 2'b00;
    Branch    = 2'b00;
    MemRead   = 1'b0;
    MemWrite  = 1'b0;
    MemtoReg  = 1'b0;

    case (instr_op_i)
        R_type: begin // R-type
            ALUop     = 2'b10;
            ALUSrc    = 1'b0;
            RegWrite  = 1'b1;
            RegDst    = 2'b01; // rd
            Branch    = 2'b00;
            MemRead   = 1'b0;
            MemWrite  = 1'b0;
            MemtoReg  = 1'b0;
        end
        ADDI: begin // addi
            ALUop     = 2'b00; // add
            ALUSrc    = 1'b1;
            RegWrite  = 1'b1;
            RegDst    = 2'b00; // rt
            MemtoReg  = 1'b0;
        end
        LW: begin // lw
            ALUop     = 2'b00; // add address
            ALUSrc    = 1'b1;
            RegWrite  = 1'b1;
            RegDst    = 2'b00; // rt
            MemRead   = 1'b1;
            MemtoReg  = 1'b1; // from DMEM
        end
        SW: begin // sw
            ALUop     = 2'b00; // add address
            ALUSrc    = 1'b1;
            MemWrite  = 1'b1;
        end
        BEQ: begin // beq
            ALUop     = 2'b01; // sub for compare
            Branch    = 2'b01;
        end
        BNE: begin // bne
            ALUop     = 2'b01; // sub for compare
            Branch    = 2'b10;
        end
    endcase
end

assign ALUOp_o    = ALUop;
assign ALUSrc_o    = ALUSrc;
assign RegWrite_o  = RegWrite;
assign RegDst_o    = RegDst;
assign Branch_o    = Branch;
assign MemRead_o   = MemRead;
assign MemWrite_o  = MemWrite;
assign MemtoReg_o  = MemtoReg;

endmodule