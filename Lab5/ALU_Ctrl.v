// ID
module ALU_Ctrl(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);
          
// TO DO
input  [1:0] ALUOp_i;
input  [5:0] funct_i;
output [3:0] ALUCtrl_o;

localparam [3:0] //ALU signal
  ADD = 4'b0010,
  SUB = 4'b0110,
  AND = 4'b0000,
  OR  = 4'b0001,
  NOR = 4'b1100,
  SLT = 4'b0111;

localparam [5:0] //funct field
  funct_ADD  = 6'b100011, // add
  funct_SUB  = 6'b100001, // sub
  funct_AND  = 6'b100110, // and
  funct_OR   = 6'b100101, // or
  funct_NOR  = 6'b101011, // nor
  funct_SLT  = 6'b101000; // slt

//TODO
reg [3:0] r;
always @(*) begin
  case (ALUOp_i) //ALUop
    2'b00: r = 4'b0010; // add
    2'b01: r = 4'b0110; // sub
    2'b10: begin
      case (funct_i)
        funct_ADD: r = ADD; // add
        funct_SUB: r = SUB; // sub
        funct_AND: r = AND; // and
        funct_OR : r = OR; // or
        funct_NOR: r = NOR; // nor
        funct_SLT: r = SLT; // slt
      endcase
    end
  endcase
end
assign ALUCtrl_o = r;

endmodule
