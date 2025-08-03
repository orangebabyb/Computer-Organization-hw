`timescale 1ns/1ps

module testbench;

    reg src1, src2, select;
    wire result;

    // 實例化 MUX 模組
    MUX_2to1 uut (
        .src1(src1),
        .src2(src2),
        .select(select),
        .result(result)
    );

    initial begin
        $display("select src1 src2 | result");
        $display("-------------------------");

        src1 = 0; src2 = 0; select = 0; #10;
        $display("   %b      %b     %b  |   %b", select, src1, src2, result);

        src1 = 1; src2 = 0; select = 0; #10;
        $display("   %b      %b     %b  |   %b", select, src1, src2, result);

        src1 = 0; src2 = 1; select = 1; #10;
        $display("   %b      %b     %b  |   %b", select, src1, src2, result);

        src1 = 1; src2 = 1; select = 1; #10;
        $display("   %b      %b     %b  |   %b", select, src1, src2, result);

        $finish;
    end
endmodule
