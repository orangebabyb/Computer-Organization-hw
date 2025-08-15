// ID
module Forwarding_Unit(
    regwrite_mem,
    regwrite_wb,
    idex_regs,
    idex_regt,
    exmem_regd,
    memwb_regd,
    forwarda,
    forwardb
);

// TO DO
input        regwrite_mem;
input        regwrite_wb;
input  [4:0] idex_regs;
input  [4:0] idex_regt;
input  [4:0] exmem_regd;
input  [4:0] memwb_regd;
output [1:0] forwarda;
output [1:0] forwardb;

reg [1:0] fa, fb;

always @(*) begin
    // default: no forwarding
    fa = 2'b00;
    fb = 2'b00;

    // EX hazard has higher priority than MEM hazard
    if (regwrite_mem && (exmem_regd != 5'd0) && (exmem_regd == idex_regs))
        fa = 2'b10;
    else if (regwrite_wb && (memwb_regd != 5'd0) && (memwb_regd == idex_regs))
        fa = 2'b01;

    if (regwrite_mem && (exmem_regd != 5'd0) && (exmem_regd == idex_regt))
        fb = 2'b10;
    else if (regwrite_wb && (memwb_regd != 5'd0) && (memwb_regd == idex_regt))
        fb = 2'b01;
end

assign forwarda = fa;
assign forwardb = fb;

endmodule