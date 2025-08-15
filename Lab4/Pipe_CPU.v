// ID A133634

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"

`timescale 1ns / 1ps

module Pipe_CPU(
    clk_i,
    rst_i
    );

input clk_i;
input rst_i;

//TODO IF stage
// wires
wire [31:0] pc_now, pc_next, pc_plus4, instr_IF;

// component
ProgramCounter PC(
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .pc_in_i(pc_next),
    .pc_out_o(pc_now)
);

Adder PCplus4(
    .src1_i (pc_now),
    .src2_i (32'd4),
    .sum_o  (pc_plus4)
);

Instruction_Memory IM(
    .addr_i (pc_now),
    .instr_o(instr_IF)
);

// IF/ID pipeline register
wire [31:0] pc_now_ID, instr_ID;
Pipe_Reg #(.size(32+32)) IF_ID (
    .clk_i (clk_i), .rst_i(rst_i),
    .data_i({pc_plus4, instr_IF}),
    .data_o({pc_now_ID, instr_ID})
);

//TODO ID stage
// decode fields wires
wire [5:0]  op_ID     = instr_ID[31:26];
wire [4:0]  rs_ID     = instr_ID[25:21];
wire [4:0]  rt_ID     = instr_ID[20:16];
wire [4:0]  rd_ID     = instr_ID[15:11];
wire [15:0] imm_ID    = instr_ID[15:0];
wire [5:0]  funct_ID  = instr_ID[5:0];

// control and datapath wires
wire [1:0]  ALUOp_ID, RegDst_ID, Branch_ID;
wire        ALUSrc_ID, RegWrite_ID, MemRead_ID, MemWrite_ID, MemtoReg_ID;
wire [31:0] rd1_ID, rd2_ID, imm_sext_ID;

// Decoder
Decoder DEC(
    .instr_op_i(op_ID),
    .ALUOp_o   (ALUOp_ID),
    .ALUSrc_o  (ALUSrc_ID),
    .RegWrite_o(RegWrite_ID),
    .RegDst_o  (RegDst_ID),
    .Branch_o  (Branch_ID),
    .MemRead_o (MemRead_ID),
    .MemWrite_o(MemWrite_ID),
    .MemtoReg_o(MemtoReg_ID)
);

// Register File
wire [4:0]  write_reg_WB;
wire [31:0] wb_data_WB; //write data from WB
wire        RegWrite_WB; //RegWrite signal

Reg_File RF(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .RSaddr_i   (rs_ID),
    .RTaddr_i   (rt_ID),
    .RDaddr_i   (write_reg_WB),
    .RDdata_i   (wb_data_WB),
    .RegWrite_i (RegWrite_WB),
    .RSdata_o   (rd1_ID),
    .RTdata_o   (rd2_ID)
);

// Sign-extend immediately
Sign_Extend SE(
    .data_i(imm_ID),
    .data_o(imm_sext_ID)
);

// ID/EX pipeline register (datapath)
wire [31:0] rd1_EX, rd2_EX, imm_EX, sign_extend_EX, pc_now_EX;
wire [4:0]  rt_EX, rd_EX; //reg destination
wire [5:0]  funct_EX;

// ID/EX pipeline register (control)
wire [1:0]  RegDst_EX, Branch_EX, ALUOp_EX;
wire        ALUSrc_EX, RegWrite_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX;

Pipe_Reg #(.size(32+32+32+5+5+6+2+1+1+1+1+2+1+32+2)) ID_EX (
    .clk_i (clk_i), .rst_i(rst_i),
    .data_i({rd1_ID, rd2_ID, imm_sext_ID, rt_ID, rd_ID, funct_ID, ALUOp_ID,
             ALUSrc_ID, RegWrite_ID, MemRead_ID, MemWrite_ID, RegDst_ID, MemtoReg_ID,
             pc_now_ID, Branch_ID}),
    .data_o({rd1_EX, rd2_EX, imm_EX, rt_EX, rd_EX, funct_EX, ALUOp_EX,
             ALUSrc_EX, RegWrite_EX, MemRead_EX, MemWrite_EX, RegDst_EX, MemtoReg_EX,
             pc_now_EX, Branch_EX})
);

//TODO EX stage
// wires
wire [3:0]  ALUctrl_EX;
wire [31:0] alu_srcB_EX, alu_res_EX;
wire        zero_EX;
wire [4:0]  write_reg_EX;
wire [31:0] branch_target_EX;

// component
Shift_Left_Two_32 SL2_EX(
    .data_i(imm_EX),
    .data_o(sign_extend_EX)
);

Adder BranchAdder(
    .src1_i(pc_now_EX),
    .src2_i(sign_extend_EX),
    .sum_o (branch_target_EX)
);

ALU_Ctrl ALUCTRL(
    .ALUOp_i   (ALUOp_EX),
    .funct_i   (funct_EX),
    .ALUCtrl_o (ALUctrl_EX)
);

MUX_2to1 #(32) ALUSrcBMux(
    .data0_i (rd2_EX),
    .data1_i (imm_EX),
    .select_i(ALUSrc_EX),
    .data_o  (alu_srcB_EX)
);

MUX_2to1 #(5)  RegDstMux(
    .data0_i (rt_EX),
    .data1_i (rd_EX),
    .select_i(RegDst_EX[0]),
    .data_o  (write_reg_EX)
);

ALU ALU0(
    .src1_i  (rd1_EX),
    .src2_i  (alu_srcB_EX),
    .ctrl_i  (ALUctrl_EX),
    .result_o(alu_res_EX),
    .zero_o  (zero_EX)
);

// EX/MEM pipeline register (datapath)
wire [31:0] alu_res_MEM, rd2_MEM, branch_target_MEM;
wire        zero_MEM;
wire [4:0]  write_reg_MEM;
wire [31:0] dmem_rd_MEM;

// EX/MEM pipeline register (control)
wire [1:0]  Branch_MEM;
wire        RegWrite_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM;

Pipe_Reg #(.size(32+32+1+32+2+1+1+1+1+5)) EX_MEM (
    .clk_i (clk_i), .rst_i(rst_i),
    .data_i({alu_res_EX, rd2_EX, zero_EX, branch_target_EX, Branch_EX,
             RegWrite_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, write_reg_EX}),
    .data_o({alu_res_MEM, rd2_MEM, zero_MEM, branch_target_MEM, Branch_MEM,
             RegWrite_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM, write_reg_MEM})
);

//TODO MEM stage
// wires
wire take_beq, take_bne, take_branch;

// Data Memory
Data_Memory DM(
    .clk_i     (clk_i),
    .addr_i    (alu_res_MEM),
    .data_i    (rd2_MEM),
    .MemRead_i (MemRead_MEM),
    .MemWrite_i(MemWrite_MEM),
    .data_o    (dmem_rd_MEM)
);

// Branch desicion
assign take_beq  = (Branch_MEM == 2'b01) &&  (zero_MEM);
assign take_bne  = (Branch_MEM == 2'b10) && ~(zero_MEM);
assign take_branch = take_beq | take_bne;

MUX_2to1 #(32) PCSrcMux(
    .data0_i (pc_plus4),
    .data1_i (branch_target_MEM),
    .select_i(take_branch),
    .data_o  (pc_next)
);

// MEM/WB pipeline register (datapath)
wire [31:0] alu_res_WB, dmem_rd_WB;

// MEM/WB pipeline register (control)
wire        MemtoReg_WB;
wire        RegWrite_WB_int;

Pipe_Reg #(.size(32+32+1+1+5)) MEM_WB (
    .clk_i (clk_i), .rst_i(rst_i),
    .data_i({alu_res_MEM, dmem_rd_MEM, MemtoReg_MEM, RegWrite_MEM, write_reg_MEM}),
    .data_o({alu_res_WB,  dmem_rd_WB,  MemtoReg_WB,  RegWrite_WB_int, write_reg_WB})
);

//TODO WB stage
// write back selection
MUX_2to1 #(32) MemtoRegMux(
    .data0_i (alu_res_WB),
    .data1_i (dmem_rd_WB),
    .select_i(MemtoReg_WB),
    .data_o  (wb_data_WB)
);

// 將 RegWrite_WB_int 轉交給 RF 的 RegWrite_i
assign RegWrite_WB = RegWrite_WB_int;


endmodule