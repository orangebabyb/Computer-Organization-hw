// student ID: A133634
module ALU(
	src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o,
	overflow
	);
     
// I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;
input  [4-1:0]   ctrl_i;

output [32-1:0]	 result_o;
output           zero_o;
output           overflow;

// Internal signals
localparam [3:0]
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

reg  [31:0] res_r;
reg         ovf_r;

wire [31:0] add_res = src1_i + src2_i;
wire [31:0] sub_res = src1_i - src2_i;

// signed overflow detection
wire add_ovf = (~src1_i[31] & ~src2_i[31] &  add_res[31]) |
               ( src1_i[31] &  src2_i[31] & ~add_res[31]);

wire sub_ovf = (~src1_i[31] &  src2_i[31] &  sub_res[31]) |
               ( src1_i[31] & ~src2_i[31] & ~sub_res[31]);
			   
// shift amount: put shamt in src1[4:0], value in src2
wire [4:0] shamt = src1_i[4:0];

// Main function
always @(*) begin
  res_r = 32'b0;
  ovf_r = 1'b0;

  case (ctrl_i)
    ALU_AND: begin
      res_r = src1_i & src2_i;
      ovf_r = 1'b0;
    end

    ALU_OR: begin
      res_r = src1_i | src2_i;
      ovf_r = 1'b0;
    end

    ALU_NOR: begin
      res_r = ~(src1_i | src2_i);
      ovf_r = 1'b0;
    end

    ALU_ADD: begin
      res_r = add_res;
      ovf_r = add_ovf;
    end

    ALU_SUB: begin
      res_r = sub_res;
      ovf_r = sub_ovf;
    end

    ALU_SLT: begin
      // signed comparison
      res_r = ($signed(src1_i) < $signed(src2_i)) ? 32'd1 : 32'd0;
      ovf_r = 1'b0;
    end

    ALU_SLL, ALU_SLLV: begin
      // value in src2_i, shamt in src1_i[4:0]
      res_r = src2_i << shamt;
      ovf_r = 1'b0;
    end

    ALU_SRL, ALU_SRLV: begin
      // logical right shift (no sign extension), value in src2_i
      res_r = src2_i >> shamt;
      ovf_r = 1'b0;
    end

    default: begin
      res_r = 32'b0;
      ovf_r = 1'b0;
    end
  endcase
end

assign result_o = res_r;
assign zero_o   = (res_r == 32'b0);
assign overflow = ovf_r;

endmodule





                    
                    