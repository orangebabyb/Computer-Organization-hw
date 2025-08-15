// ID
module Hazard_Detection(
    memread,
    instr_i,
    idex_regt,
    branch,
    pcwrite,
    ifid_write,
    ifid_flush,
    idex_flush,
    exmem_flush
);

// TO DO
input        memread;      // ID/EX.MemRead
input [31:0] instr_i;      // IF/ID.instr
input  [4:0] idex_regt;    // ID/EX.RT (dest for lw)
input        branch;       // branch taken (usually from MEM)
output       pcwrite;
output       ifid_write;
output       ifid_flush;
output       idex_flush;
output       exmem_flush;

// decode RS/RT from IF/ID.instr
wire [4:0] rs = instr_i[25:21];
wire [4:0] rt = instr_i[20:16];

wire load_use_hazard = memread && ((idex_regt == rs) || (idex_regt == rt));

reg pcw, ifw, if_flush, id_flush, ex_flush;

always @(*) begin
    // defaults (no stall, no flush)
    pcw      = 1'b1;
    ifw      = 1'b1;
    if_flush = 1'b0;
    id_flush = 1'b0;
    ex_flush  = 1'b0;

    // branch taken -> flushIF/ID & ID/EX & EX/MEM
    if (branch) begin
        pcw      = 1'b1; 
        ifw      = 1'b1;
        if_flush = 1'b1;   // clean IF/ID
        id_flush = 1'b1;   // clean ID/EX
        ex_flush  = 1'b1;   // clean EX/MEM
    end
    // load-use hazard -> stall PC & IF/ID, flush ID/EX
    else if (load_use_hazard) begin
        pcw      = 1'b0;   // freeze PC
        ifw      = 1'b0;   // freeze IF/ID
        if_flush = 1'b0;   
        id_flush = 1'b1;   // ID/EX insert NOP
        ex_flush  = 1'b0;
    end
end

assign pcwrite    = pcw;
assign ifid_write = ifw;
assign ifid_flush = if_flush;
assign idex_flush = id_flush;
assign exmem_flush= ex_flush;

endmodule