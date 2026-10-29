`timescale 1ns/1ps
// Testbench: jedna pełna ramka — liczba pikseli widocznych, impulsów HSYNC i długość VSYNC.
module tb_vga_timing;
    reg clk = 1'b0, rst = 1'b1;
    wire [9:0] x, y;
    wire hsync, vsync, de;
    integer n, de_cnt = 0, hs_falls = 0, vs_low = 0, hs_low_line0 = 0;
    reg hs_prev = 1'b1;

    vga_timing dut (.clk_pix(clk), .rst(rst), .x(x), .y(y), .hsync(hsync), .vsync(vsync), .de(de));
    always #20 clk = ~clk;                       // 25 MHz

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk) rst = 1'b0;
        for (n = 0; n < 800*525; n = n + 1) begin   // dokładnie jedna ramka
            @(negedge clk);
            if (de) de_cnt = de_cnt + 1;
            if (hs_prev && !hsync) hs_falls = hs_falls + 1;
            if (!vsync) vs_low = vs_low + 1;
            if (y == 0 && !hsync) hs_low_line0 = hs_low_line0 + 1;
            hs_prev = hsync;
        end
        if (de_cnt == 640*480 && hs_falls == 525 && vs_low == 2*800 && hs_low_line0 == 96)
            $display("PASS: vga_timing, %0d pikseli widocznych, %0d linii, VSYNC %0d taktów, HSYNC 96 taktów",
                     de_cnt, hs_falls, vs_low);
        else
            $display("FAIL: vga_timing, de=%0d hs=%0d vs=%0d hs_len=%0d", de_cnt, hs_falls, vs_low, hs_low_line0);
        $finish;
    end
endmodule
