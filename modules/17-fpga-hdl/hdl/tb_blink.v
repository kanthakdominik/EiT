`timescale 1ns/1ps
// Testbench: przy CLK_HZ = 20 i BLINK_HZ = 1 dioda zmienia stan co 10 taktów.
module tb_blink;
    reg clk = 1'b0;
    reg rst = 1'b1;
    wire led;
    integer toggles = 0;

    blink #(.CLK_HZ(20), .BLINK_HZ(1)) dut (.clk(clk), .rst(rst), .led(led));

    always #5 clk = ~clk;

    always @(led) if (!rst) toggles = toggles + 1;

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk) rst = 1'b0;
        repeat (200) @(posedge clk);
        #1;
        if (toggles == 20) $display("PASS: blink, %0d zmian stanu w 200 taktach", toggles);
        else               $display("FAIL: blink, %0d zmian stanu (oczekiwano 20)", toggles);
        $finish;
    end
endmodule
