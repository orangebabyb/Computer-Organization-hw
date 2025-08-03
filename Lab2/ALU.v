//Student ID:A133634
`timescale 1ns/1ps
`include "ALU_1bit.v"
module ALU(
	input                   rst_n,         // negative reset            (input)
	input	     [32-1:0]	src1,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ALU_control,   // 4 bits ALU control input  (input)
	output reg   [32-1:0]	result,        // 32 bits result            (output)
	output reg              zero,          // 1 bit when the output is 0, zero must be set (output)
	output reg              cout,          // 1 bit carry out           (output)
	output reg              overflow       // 1 bit overflow            (output)
	);
	
/* Write down your code HERE */
	wire [31:0] carry;
    wire [31:0] alu_result;
    wire        set;

    wire Ainvert = ALU_control[3];
	wire Binvert = ALU_control[2];
    wire [1:0] operation = ALU_control[1:0];

    // 32 ALU_1bit
    generate
        for (genvar i = 0; i < 32; i = i + 1) 
		begin : alu_gen
            wire less, cin;
    		assign less = (i == 0) ? set : 1'b0;
    		assign cin  = (i == 0) ? Binvert : carry[i - 1];

            ALU_1bit alu_i (
                .src1(src1[i]),
                .src2(src2[i]),
                .less(less),
                .Ainvert(Ainvert),
                .Binvert(Binvert),
                .cin(cin),
                .operation(operation),
                .result(alu_result[i]),
                .cout(carry[i])
            );
        end
    endgenerate

    // set bit for SLT
    //assign set = src1[31] ^ ~src2[31] ^ carry[30];
	wire [31:0] diff = src1 + (~src2) + 1;
	wire overflow_flag = carry[31] ^ carry[30];
	assign set = diff[31] ^ overflow_flag;

    // Assign outputs on positive edge (combinational logic style)
    always @* 
	begin
        if (!rst_n) 
		begin
            result = 32'h00000000;
            zero = 0;
            cout = 0;
            overflow = 0;
        end 
		else
		begin
            result = alu_result;
            zero = (alu_result == 32'h00000000);

            if (operation == 2'b10) 
			begin
            	cout     = carry[31];
            	overflow = carry[31] ^ carry[30]; // Overflow = cout(n) xor cout(n-1)
        	end 
			else 
			begin
            	cout     = 0;
            	overflow = 0;
        	end
        end
    end

endmodule