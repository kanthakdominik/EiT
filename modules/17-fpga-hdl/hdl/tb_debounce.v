`timescale 1ns/1ps
// Testbench: drgania krótsze niż N taktów nie mogą zmienić wyjścia;
// po każdym stabilnym stanie wyjście zmienia się dokładnie raz.
module tb_debounce;
    localparam integer N = 8;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg btn = 1'b0;
    wire out;
    integer rises = 0, falls = 0, k;

    debounce #(.N(N)) dut (.clk(clk), .rst(rst), .btn_in(btn), .btn_out(out));

    always #5 clk = ~clk;
    always @(posedge out) if (!rst) rises = rises + 1;
    always @(negedge out) if (!rst) falls = falls + 1;

    task bounce;                          // 5 krótkich impulsów po 3 takty
        begin
            for (k = 0; k < 5; k = k + 1) begin
                @(negedge clk) btn = ~btn;
                repeat (2) @(negedge clk);
            end
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk) rst = 1'b0;
        repeat (5) @(negedge clk);
        bounce;                           // drgania przy naciśnięciu (kończy się na btn = 1)
        @(negedge clk) btn = 1'b1;
        repeat (4*N) @(negedge clk);      // stabilnie wciśnięty
        bounce;                           // drgania przy puszczeniu (kończy się na btn = 0)
        @(negedge clk) btn = 1'b0;
        repeat (4*N) @(negedge clk);
        if (rises == 1 && falls == 1 && out == 1'b0)
            $display("PASS: debounce, 1 zbocze narastające i 1 opadające");
        else
            $display("FAIL: debounce, rises=%0d falls=%0d out=%b", rises, falls, out);
        $finish;
    end
endmodule
