// ID
module MUX_3to1(
               data0_i,
               data1_i,
               data2_i,
               select_i,
               data_o
               );

// TO DO
parameter size = 32;
input   [size-1:0] data0_i;          
input   [size-1:0] data1_i;
input   [size-1:0] data2_i;
input   [1:0]      select_i;
output  [size-1:0] data_o; 

//TODO
reg    [size-1:0] r;
always @(*) begin
    case (select_i)
        2'b00: r = data0_i;
        2'b01: r = data1_i;
        2'b10: r = data2_i;
    endcase
end
assign data_o = r;

endmodule      
