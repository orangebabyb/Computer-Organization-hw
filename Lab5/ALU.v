// ID
module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
// TO DO
input  [31:0] src1_i;
input  [31:0] src2_i;
input  [3:0]  ctrl_i;
output [31:0] result_o;
output        zero_o;

//TODO
reg [31:0] r;

localparam [3:0]
  ADD = 4'b0010,
  SUB = 4'b0110,
  AND = 4'b0000,
  OR  = 4'b0001,
  NOR = 4'b1100,
  SLT = 4'b0111;

always @(*) begin
    case (ctrl_i)
        AND: r = src1_i & src2_i;        // AND
        OR  : r = src1_i | src2_i;        // OR
        ADD: r = src1_i + src2_i;        // ADD
        SUB: r = src1_i - src2_i;        // SUB
        SLT: r = ($signed(src1_i) < $signed(src2_i)) ? 32'd1 : 32'd0; // SLT
        NOR: r = ~(src1_i | src2_i);     // NOR
    endcase
end
assign result_o = r;
assign zero_o   = (r == 32'd0);

endmodule