`timescale 1ns/1ps

module testbench;

    reg src1, src2, src3, src4;
    reg [1:0] select;
    wire result;

    // 實例化你寫的 MUX_4to1 模組
    MUX_4to1 uut (
        .src1(src1),
        .src2(src2),
        .src3(src3),
        .src4(src4),
        .select(select),
        .result(result)
    );

    initial begin
        $display("select src1 src2 src3 src4 | result");
        $display("-------------------------------------");

        // 測試所有輸入組合
        src1 = 0; src2 = 0; src3 = 0; src4 = 0;

        select = 2'b00; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        select = 2'b01; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        select = 2'b10; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        select = 2'b11; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        // 測試輸入變化
        src1 = 1; src2 = 0; src3 = 1; src4 = 0;

        select = 2'b00; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        select = 2'b01; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        select = 2'b10; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        select = 2'b11; #10;
        $display("  %b     %b    %b    %b    %b   |   %b", select, src1, src2, src3, src4, result);

        $finish;
    end

endmodule
