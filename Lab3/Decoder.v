// student ID: A133634
module Decoder( 
	instr_op_i,
	ALU_op_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o
);

// I/O ports
input	[6-1:0] instr_op_i;

output	reg [2-1:0] ALU_op_o;
output	reg [2-1:0] RegDst_o, MemtoReg_o;
output  reg [2-1:0] Branch_o;
output	reg		ALUSrc_o, RegWrite_o, Jump_o, MemRead_o, MemWrite_o;

// Internal Signals
//TODO op signal 
localparam [5:0]
  R_type = 6'b000000,
  LW     = 6'b101100,
  SW     = 6'b100100,
  BEQ    = 6'b000110,
  BNE    = 6'b000101,
  ADDI   = 6'b001001,
  J      = 6'b000111,
  JAL    = 6'b000011;

// Main function
always @(*) begin
  RegWrite_o = 1'b0;
  ALUSrc_o   = 1'b0;
  RegDst_o   = 2'b00;
  Branch_o   = 2'b00;
  Jump_o     = 1'b0;
  MemRead_o  = 1'b0;
  MemWrite_o = 1'b0;
  MemtoReg_o = 2'b00;
  ALU_op_o   = 2'b00; // default add

  case (instr_op_i)
    R_type: begin
      RegWrite_o = 1'b1;
      ALUSrc_o   = 1'b0;
      RegDst_o   = 2'b10;     // rd
      ALU_op_o   = 2'b10;     // use funct
      MemtoReg_o = 2'b00;     // ALU
    end

    LW: begin
      RegWrite_o = 1'b1;
      ALUSrc_o   = 1'b1;      // base + imm
      RegDst_o   = 2'b00;     // rt
      MemRead_o  = 1'b1;
      MemtoReg_o = 2'b01;     // from MEM
      ALU_op_o   = 2'b00;     // add
    end

    SW: begin
      RegWrite_o = 1'b0;
      ALUSrc_o   = 1'b1;
      MemWrite_o = 1'b1;
      ALU_op_o   = 2'b00;     // add
    end

    BEQ: begin
      RegWrite_o = 1'b0;
      ALUSrc_o   = 1'b0;
      Branch_o   = 2'b01;     // beq
      ALU_op_o   = 2'b01;     // sub for compare
    end

    BNE: begin
      RegWrite_o = 1'b0;
      ALUSrc_o   = 1'b0;
      Branch_o   = 2'b10;     // bne
      ALU_op_o   = 2'b01;     // sub
    end

    ADDI: begin
      RegWrite_o = 1'b1;
      ALUSrc_o   = 1'b1;
      RegDst_o   = 2'b00;     // rt
      MemtoReg_o = 2'b00;     // ALU
      ALU_op_o   = 2'b00;     // add
    end

    J: begin
      Jump_o     = 1'b1;
    end

    JAL: begin
      Jump_o     = 1'b1;
      RegWrite_o = 1'b1;      // write $ra
      RegDst_o   = 2'b01;     // select $ra (31)
      MemtoReg_o = 2'b10;     // write PC+4
    end
  endcase
end

endmodule
                

