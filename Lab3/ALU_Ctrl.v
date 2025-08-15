// student ID
module ALU_Ctrl(
        funct_i,
        ALUOp_i,
        ALUCtrl_o
        );
          
// I/O ports 
input      [6-1:0] funct_i;
input      [2-1:0] ALUOp_i;

output reg [4-1:0] ALUCtrl_o;  
     
// Internal Signals
localparam [3:0] // ALU
  ALU_AND  = 4'b0000,
  ALU_OR   = 4'b0001,
  ALU_ADD  = 4'b0010,
  ALU_SUB  = 4'b0110,
  ALU_SLT  = 4'b0111,
  ALU_NOR  = 4'b1100,
  ALU_SLL  = 4'b1000,
  ALU_SRL  = 4'b1001,
  ALU_SLLV = 4'b1010,
  ALU_SRLV = 4'b1011,
  ALU_JR   = 4'b1111;

localparam [5:0] //funct field
  ADD  = 6'b100011, // add
  SUB  = 6'b100001, // sub
  AND  = 6'b100110, // and
  OR   = 6'b100101, // or
  NOR  = 6'b101011, // nor
  SLT  = 6'b101000, // slt
  SLL  = 6'b000010, // sll
  SRL  = 6'b000100, // srl
  SLLV = 6'b000110, // sllv
  SRLV = 6'b001000, // srlv
  JR   = 6'b001100; // JR

// Main function
always @(*) begin
  case (ALUOp_i)
    2'b00: ALUCtrl_o = ALU_ADD; // lw/sw/addi
    2'b01: ALUCtrl_o = ALU_SUB; // beq/bne
    2'b10: begin               // R-type by funct
      case (funct_i)
        AND:  ALUCtrl_o = ALU_AND;
        OR:   ALUCtrl_o = ALU_OR;
        NOR:  ALUCtrl_o = ALU_NOR;
        ADD:  ALUCtrl_o = ALU_ADD;
        SUB:  ALUCtrl_o = ALU_SUB;
        SLT:  ALUCtrl_o = ALU_SLT;
        SLL:  ALUCtrl_o = ALU_SLL;
        SRL:  ALUCtrl_o = ALU_SRL;
        SLLV: ALUCtrl_o = ALU_SLLV;
        SRLV: ALUCtrl_o = ALU_SRLV;
        JR:   ALUCtrl_o = ALU_JR;
      endcase
    end
  endcase
end 

endmodule