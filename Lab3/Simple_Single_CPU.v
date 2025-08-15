// student ID: A133634

`include "ProgramCounter.v"
`include "Instr_Memory.v"
`include "Reg_File.v"
`include "Data_Memory.v"

//TODO include module
`include "Adder.v"
`include "ALU.v"
`include "ALU_Ctrl.v"
`include "Decoder.v"
`include "Sign_Extend.v"
`include "Shift_Left_Two_32.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"

module Simple_Single_CPU(
        clk_i,
	rst_i
);
		
// I/O port
input         clk_i;
input         rst_i;

//TODO Internal Signals
// PC / Instruction
wire [31:0] pc_now, pc_next, pc_plus4, pc_branch, pc_jump;
wire [31:0] instr;

// Fields
wire [5:0]  op    = instr[31:26];
wire [4:0]  rs    = instr[25:21];
wire [4:0]  rt    = instr[20:16];
wire [4:0]  rd    = instr[15:11];
wire [4:0]  shamt = instr[10:6];
wire [5:0]  funct = instr[5:0];
wire [15:0] imm16 = instr[15:0];
wire [25:0] jidx  = instr[25:0];

// Control
wire [1:0] ALUOp;
wire [1:0] RegDst;
wire [1:0] Branch;
wire       ALUSrc, RegWrite, Jump, MemRead, MemWrite;
wire [1:0] MemtoReg;

// Register File
wire [31:0] rs_data, rt_data;
wire [4:0]  rd_sel;
wire [31:0] wb_data;

// ALU
wire [3:0]  ALUCtrl;
wire [31:0] alu_src1, alu_src2, alu_result;
wire        alu_zero, alu_overflow;

// Imm & shift
wire [31:0] imm_ext;
wire [31:0] imm_sl2;

// data memory output
wire [31:0] mem_rdata;

// Components
ProgramCounter PC(
        .clk_i(clk_i),      
        .rst_i(rst_i),     
        .pc_in_i(pc_next),   
        .pc_out_o(pc_now) 
);

Instr_Memory IM(
        .pc_addr_i(pc_now),  
        .instr_o(instr)    
);

Reg_File Registers(
        .clk_i(clk_i),
        .rst_i(rst_i) ,     
        .RSaddr_i(rs),
        .RTaddr_i(rt),
        .RDaddr_i(rd_sel), 
        .RDdata_i(wb_data),
        .RegWrite_i(RegWrite),
        .RSdata_o(rs_data),  
        .RTdata_o(rt_data) 
);
	
Data_Memory Data_Memory(
	.clk_i(clk_i), 
	.addr_i(alu_result), 
	.data_i(rt_data), 
	.MemRead_i(MemRead), 
	.MemWrite_i(MemWrite), 
	.data_o(mem_rdata)
);

//TODO Components
// PC + 4
Adder Add_PC(
        .src1_i(pc_now),
        .src2_i(32'd4),
        .sum_o (pc_plus4)
);

// Main Decoder
Decoder Decoder(
        .instr_op_i(op),
        .ALU_op_o  (ALUOp),
        .ALUSrc_o  (ALUSrc),
        .RegWrite_o(RegWrite),
        .RegDst_o  (RegDst),
        .Branch_o  (Branch),
        .Jump_o    (Jump),
        .MemRead_o (MemRead),
        .MemWrite_o(MemWrite),
        .MemtoReg_o(MemtoReg)
);

// Sign-extend
Sign_Extend SE(
        .data_i(imm16),
        .data_o(imm_ext)
);

// Shift-left-2
Shift_Left_Two_32 SL2(
        .data_i(imm_ext),
        .data_o(imm_sl2)
);

// Branch target
Adder Add_Branch(
        .src1_i(pc_now), //pc_plus4 
        .src2_i(imm_sl2),
        .sum_o (pc_branch)
);

// ALU Ctrl
ALU_Ctrl ALUCTRL(
        .funct_i (funct),
        .ALUOp_i (ALUOp),
        .ALUCtrl_o(ALUCtrl)
);

//TODO ALU inputs
wire is_shift_imm = (ALUOp == 2'b10) && ((funct == 6'b000010) || (funct == 6'b000100)); // sll/srl
wire [31:0] shamt32 = {27'b0, shamt};

MUX_2to1 #(.size(32)) MUX_ALUSrc1(
        .data0_i (rs_data),
        .data1_i (shamt32),
        .select_i(is_shift_imm),
        .data_o  (alu_src1)
);

// ALUSrc: 0→rt_data, 1→SignExt(imm)
MUX_2to1 #(.size(32)) MUX_ALUSrc2(
        .data0_i (rt_data),
        .data1_i (imm_ext),
        .select_i(ALUSrc),
        .data_o  (alu_src2)
);

// ALU
ALU ALU(
        .src1_i  (alu_src1),
        .src2_i  (alu_src2),
        .ctrl_i  (ALUCtrl),
        .result_o(alu_result),
        .zero_o  (alu_zero),
        .overflow(alu_overflow)
);

//TODO Write-back
wire [4:0] ra = 5'd31;

MUX_3to1 #(.size(5)) MUX_RegDst(
        .data0_i (rt),
        .data1_i (ra),
        .data2_i (rd),
        .select_i(RegDst),
        .data_o  (rd_sel)
);

MUX_3to1 #(.size(32)) MUX_MemtoReg(
        .data0_i (alu_result),
        .data1_i (mem_rdata),
        .data2_i (pc_plus4),
        .select_i(MemtoReg),
        .data_o  (wb_data)
);

//TODO next PC Logic
// BEQ/BNE
wire take_beq = (Branch == 2'b01) &  (alu_zero);
wire take_bne = (Branch == 2'b10) & (~alu_zero);
wire PCSrc    = take_beq | take_bne;

wire [31:0] pc_after_branch;
MUX_2to1 #(.size(32)) MUX_PCBranch(
        .data0_i (pc_plus4),
        .data1_i (pc_branch),
        .select_i(PCSrc),
        .data_o  (pc_after_branch)
);

// Jump target = {PC+4[31:28], instr[25:0], 2'b00}
assign pc_jump = { pc_plus4[31:28], jidx, 2'b00 };

MUX_2to1 #(.size(32)) MUX_PCJump(
        .data0_i (pc_after_branch),
        .data1_i (pc_jump),
        .select_i(Jump),
        .data_o  (pc_next)
);

endmodule
