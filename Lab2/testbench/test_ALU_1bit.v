`timescale 1ns/1ps

module test_ALU_1bit;

    reg src1, src2, less, Ainvert, Binvert, cin;
    reg [1:0] operation;
    wire result, cout;

    ALU_1bit uut (
        .src1(src1),
        .src2(src2),
        .less(less),
        .Ainvert(Ainvert),
        .Binvert(Binvert),
        .cin(cin),
        .operation(operation),
        .result(result),
        .cout(cout)
    );

    initial begin
        $display("Func  Ain Bin Cin op  | A B | Res Cout | Expect");
        $display("----------------------------------------------");

        // AND
        src1=1; src2=1; Ainvert=0; Binvert=0; cin=0; less=0; operation=2'b01;
        #1 $display("AND   %b   %b   %b  %b%b | %b %b |  %b    %b   |  1 0", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        // OR
        src1=1; src2=0; Ainvert=0; Binvert=0; cin=0; less=0; operation=2'b00;
        #1 $display("OR    %b   %b   %b  %b%b | %b %b |  %b    %b   |  1 0", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        // ADD
        src1=1; src2=1; Ainvert=0; Binvert=0; cin=0; less=0; operation=2'b10;
        #1 $display("ADD   %b   %b   %b  %b%b | %b %b |  %b    %b   |  0 1", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        // SUB
        src1=1; src2=1; Ainvert=0; Binvert=1; cin=1; less=0; operation=2'b10;
        #1 $display("SUB   %b   %b   %b  %b%b | %b %b |  %b    %b   |  0 1", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        // NOR
        src1=1; src2=1; Ainvert=1; Binvert=1; cin=0; less=0; operation=2'b01;
        #1 $display("NOR   %b   %b   %b  %b%b | %b %b |  %b    %b   |  0 0", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);
        
        // NOR2
        src1=0; src2=0; Ainvert=1; Binvert=1; cin=0; less=0; operation=2'b01;
        #1 $display("NOR   %b   %b   %b  %b%b | %b %b |  %b    %b   |  1 0", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        // NAND
        src1=1; src2=1; Ainvert=1; Binvert=1; cin=0; less=0; operation=2'b00;
        #1 $display("NAND  %b   %b   %b  %b%b | %b %b |  %b    %b   |  0 0", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        // NAND2
        src1=0; src2=1; Ainvert=1; Binvert=1; cin=0; less=0; operation=2'b00;
        #1 $display("NAND  %b   %b   %b  %b%b | %b %b |  %b    %b   |  1 0", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        // SLT
        src1=0; src2=0; Ainvert=0; Binvert=1; cin=1; less=0; operation=2'b11;
        #1 $display("SLT   %b   %b   %b  %b%b | %b %b |  %b    %b   |  0 0", Ainvert, Binvert, cin, operation[1], operation[0], src1, src2, result, cout);

        $finish;
    end

endmodule