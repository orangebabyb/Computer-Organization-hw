// ID 

`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Forwarding_Unit.v"
`include "Hazard_Detection.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Reg_File.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"

`timescale 1ns / 1ps

module Pipe_CPU_PRO(
    clk_i,
    rst_i
);
    
input clk_i;
input rst_i;

// TO DO
//TODO IF stage 
wire [31:0] pc_now, pc_calc_next, pc_plus4, instr_IF;
wire pcwrite;

ProgramCounter PC(
    .clk_i  (clk_i),
    .rst_i  (rst_i),
    .pc_write (pcwrite), //control by hazard detection
    .pc_in_i(pc_calc_next),
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

//TODO IF/ID pipeline resigter 
wire [31:0] pc_now_ID, instr_ID;
wire        ifid_write, ifid_flush;
wire        idex_flush, exmem_flush;

wire [63:0] IFID_bus_out;

Pipe_Reg #(.size(32+32)) IF_ID (
    .clk_i (clk_i), .rst_i(rst_i),
    .flush (ifid_flush),
    .write (ifid_write),     
    .data_i({pc_now, instr_IF}),
    .data_o({pc_now_ID, instr_ID})
);

// PC hold when pcwrite==0
wire [31:0] pc_after_branch;
assign pc_calc_next = pc_after_branch;

//TODO ID stage 
wire [5:0]  op_ID     = instr_ID[31:26];
wire [4:0]  rs_ID     = instr_ID[25:21];
wire [4:0]  rt_ID     = instr_ID[20:16];
wire [4:0]  rd_ID     = instr_ID[15:11];
wire [15:0] imm_ID    = instr_ID[15:0];
wire [5:0]  funct_ID  = instr_ID[5:0];

wire [31:0] rd1_ID, rd2_ID, imm_sext_ID;
wire [1:0]  ALUOp_ID;
wire        ALUSrc_ID, RegWrite_ID, RegDst_ID, Branch_ID;
wire        MemRead_ID, MemWrite_ID, MemtoReg_ID, BranchType_ID;

// Decoder
Decoder DEC(
    .instr_op_i  (op_ID),
    .ALUOp_o     (ALUOp_ID),
    .ALUSrc_o    (ALUSrc_ID),
    .RegWrite_o  (RegWrite_ID),
    .RegDst_o    (RegDst_ID),
    .Branch_o    (Branch_ID),
    .MemRead_o   (MemRead_ID),
    .MemWrite_o  (MemWrite_ID),
    .MemtoReg_o  (MemtoReg_ID),
    .BranchType_o(BranchType_ID)
);

wire [31:0] wb_data_WB;
wire [4:0]  write_reg_WB;
wire        RegWrite_WB;

// Register File
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

Sign_Extend SE(
    .data_i(imm_ID), 
    .data_o(imm_sext_ID)
);

// Hazard Detection unit
wire [4:0] ID_EX_RT_for_hzd;
wire       ID_EX_MemRead_for_hzd;
wire       take_branch; // from MEM stage

Hazard_Detection HDU(
    .memread    (ID_EX_MemRead_for_hzd),
    .instr_i    (instr_ID),
    .idex_regt  (ID_EX_RT_for_hzd),
    .branch     (take_branch),
    .pcwrite    (pcwrite),
    .ifid_write (ifid_write),
    .ifid_flush (ifid_flush),
    .idex_flush (idex_flush),
    .exmem_flush(exmem_flush)
);

//TODO ID/EX pipeline resigter
// datapath
wire [31:0] rd1_EX, rd2_EX, imm_EX, sl2_EX, pc_now_EX;
wire [4:0]  rs_EX, rt_EX, rd_EX;
wire [5:0]  funct_EX;
// control (raw)
wire [1:0]  ALUOp_EX_raw;
wire        ALUSrc_EX_raw, RegWrite_EX_raw, RegDst_EX_raw;
wire        MemRead_EX_raw, MemWrite_EX_raw, MemtoReg_EX_raw;
wire        Branch_EX_raw, BranchType_EX_raw;
// control after flush
wire [1:0]  ALUOp_EX;
wire        ALUSrc_EX, RegWrite_EX, RegDst_EX;
wire        MemRead_EX, MemWrite_EX, MemtoReg_EX;
wire        Branch_EX, BranchType_EX;

Pipe_Reg #(.size(32+32+32+5+5+5+6+2+1+1+1+1+1+1+32+1+1)) ID_EX (
    .clk_i (clk_i), .rst_i(rst_i),
    .flush (idex_flush), // flush on  load-use or branch 
    .write (1'b1), // No stall
    .data_i({rd1_ID, rd2_ID, imm_sext_ID, rs_ID, rt_ID, rd_ID, funct_ID, ALUOp_ID,
             ALUSrc_ID, RegWrite_ID, MemRead_ID, MemWrite_ID, RegDst_ID, MemtoReg_ID,
             pc_now_ID, Branch_ID, BranchType_ID}),
    .data_o({rd1_EX, rd2_EX, imm_EX,       rs_EX, rt_EX, rd_EX, funct_EX, ALUOp_EX_raw,
             ALUSrc_EX_raw, RegWrite_EX_raw, MemRead_EX_raw, MemWrite_EX_raw, RegDst_EX_raw, MemtoReg_EX_raw,
             pc_now_EX, Branch_EX_raw, BranchType_EX_raw})
);

// raw control
assign ALUOp_EX      = ALUOp_EX_raw;
assign ALUSrc_EX     = ALUSrc_EX_raw;
assign RegWrite_EX   = RegWrite_EX_raw;
assign MemRead_EX    = MemRead_EX_raw;
assign MemWrite_EX   = MemWrite_EX_raw;
assign RegDst_EX     = RegDst_EX_raw;
assign MemtoReg_EX   = MemtoReg_EX_raw;
assign Branch_EX     = Branch_EX_raw;
assign BranchType_EX = BranchType_EX_raw;

// 暴露給 HDU
assign ID_EX_RT_for_hzd      = rt_EX;
assign ID_EX_MemRead_for_hzd = MemRead_EX;

//TODO EX stage 
wire [3:0]  ALUctrl_EX;
wire [31:0] alu_srcA_EX, alu_srcB_EX, alu_res_EX;
wire        zero_EX;
wire [4:0]  write_reg_EX;
wire [31:0] branch_target_EX;

Shift_Left_Two_32 SL2_EX(
    .data_i(imm_EX),
    .data_o(sl2_EX)
);

Adder BranchAdder(
    .src1_i(pc_now_EX),
    .src2_i(sl2_EX),
    .sum_o (branch_target_EX)
);

ALU_Ctrl ALUCTRL(
    .ALUOp_i   (ALUOp_EX),
    .funct_i   (funct_EX),
    .ALUCtrl_o (ALUctrl_EX)
);

MUX_2to1 #(5) RegDstMux(
    .data0_i (rt_EX),
    .data1_i (rd_EX),
    .select_i(RegDst_EX),
    .data_o  (write_reg_EX)
);

// Forwarding Unit
wire [1:0] forwarda, forwardb;

Forwarding_Unit FU(
    .regwrite_mem(RegWrite_MEM),
    .regwrite_wb (RegWrite_WB),
    .idex_regs   (rs_EX),
    .idex_regt   (rt_EX),
    .exmem_regd  (write_reg_MEM),
    .memwb_regd  (write_reg_WB),
    .forwarda    (forwarda),
    .forwardb    (forwardb)
);

// MUX for forwarding rs
MUX_3to1 #(32) FwdMuxA(
    .data0_i (rd1_EX),
    .data1_i (wb_data_WB),
    .data2_i (alu_res_MEM),
    .select_i(forwarda),
    .data_o  (alu_srcA_EX)
);

// MUX for forwarding rt
wire [31:0] rt_data_fwd_EX;
MUX_3to1 #(32) FwdMuxB(
    .data0_i (rd2_EX),
    .data1_i (wb_data_WB),
    .data2_i (alu_res_MEM),
    .select_i(forwardb),
    .data_o  (rt_data_fwd_EX)
);

// ALUSrc mux: imm vs forwarded RT
MUX_2to1 #(32) ALUSrcBMux(
    .data0_i (rt_data_fwd_EX),
    .data1_i (imm_EX),
    .select_i(ALUSrc_EX),
    .data_o  (alu_srcB_EX)
);

ALU ALU0(
    .src1_i  (alu_srcA_EX),
    .src2_i  (alu_srcB_EX),
    .ctrl_i  (ALUctrl_EX),
    .result_o(alu_res_EX),
    .zero_o  (zero_EX)
);

//TODO EX/MEM pipeline resigter
wire [31:0] rd2_MEM;
wire        Branch_MEM, BranchType_MEM;
wire        RegWrite_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM;
wire [4:0]  write_reg_MEM;
wire [31:0] alu_res_MEM, branch_target_MEM;

Pipe_Reg #(.size(32+32+1+32+1+1+1+1+1+1+5)) EX_MEM (
    .clk_i (clk_i), .rst_i(rst_i),
    .flush (exmem_flush),  // Hazard Detection control exmem_flush
    .write (1'b1),
    .data_i({alu_res_EX, rt_data_fwd_EX, zero_EX, branch_target_EX, Branch_EX, BranchType_EX,
             RegWrite_EX, MemRead_EX, MemWrite_EX, MemtoReg_EX, write_reg_EX}),
    .data_o({alu_res_MEM, rd2_MEM,      zero_MEM, branch_target_MEM, Branch_MEM, BranchType_MEM,
             RegWrite_MEM, MemRead_MEM, MemWrite_MEM, MemtoReg_MEM, write_reg_MEM})
);

//TODO MEM stage 
wire [31:0] dmem_rd_MEM;

Data_Memory DM(
    .clk_i     (clk_i),
    .addr_i    (alu_res_MEM),
    .data_i    (rd2_MEM),
    .MemRead_i (MemRead_MEM),
    .MemWrite_i(MemWrite_MEM),
    .data_o    (dmem_rd_MEM)
);

// branch in MEM：Branch & (Zero ^ BranchType)
assign take_branch     = Branch_MEM & (zero_MEM ^ BranchType_MEM);
assign pc_after_branch = take_branch ? branch_target_MEM : pc_plus4;

//TODO MEM/WB pipeline resigter
wire [31:0] alu_res_WB, dmem_rd_WB;
wire        MemtoReg_WB, RegWrite_WB_int;

Pipe_Reg #(.size(32+32+1+1+5)) MEM_WB (
    .clk_i (clk_i), .rst_i(rst_i),
    .flush (1'b0),
    .write (1'b1),
    .data_i({alu_res_MEM, dmem_rd_MEM, MemtoReg_MEM, RegWrite_MEM, write_reg_MEM}),
    .data_o({alu_res_WB,  dmem_rd_WB,  MemtoReg_WB,  RegWrite_WB_int, write_reg_WB })
);

//TODO WB stage 
MUX_2to1 #(32) MemtoRegMux(
    .data0_i(alu_res_WB), 
    .data1_i(dmem_rd_WB), 
    .select_i(MemtoReg_WB), 
    .data_o(wb_data_WB)
);
assign RegWrite_WB = RegWrite_WB_int;


endmodule