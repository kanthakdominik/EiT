`timescale 1ns/1ps
// Testbench: MOSI połączone z MISO (pętla zwrotna) — odebrany bajt musi być równy wysłanemu;
// sprawdzenie liczby zboczy SCK (8 na bajt) i powrotu CS do stanu nieaktywnego.
module tb_spi_master;
    reg clk = 1'b0, rst = 1'b1, start = 1'b0;
    reg [7:0] tx = 8'd0;
    wire [7:0] rx;
    wire done, busy, sck, mosi, cs_n;
    integer errors = 0, edges = 0, i;
    reg [7:0] pattern [0:3];

    spi_master #(.CLK_DIV(4)) dut (.clk(clk), .rst(rst), .start(start), .tx_data(tx), .rx_data(rx),
                                   .done(done), .busy(busy), .sck(sck), .mosi(mosi), .miso(mosi), .cs_n(cs_n));
    always #5 clk = ~clk;
    always @(posedge sck) if (!rst) edges = edges + 1;

    initial begin
        pattern[0] = 8'hA5; pattern[1] = 8'h3C; pattern[2] = 8'h00; pattern[3] = 8'hFF;
        repeat (3) @(posedge clk);
        @(negedge clk) rst = 1'b0;
        for (i = 0; i < 4; i = i + 1) begin
            edges = 0;
            @(negedge clk) begin tx = pattern[i]; start = 1'b1; end
            @(negedge clk) start = 1'b0;
            wait (done);
            @(negedge clk);
            if (rx !== pattern[i]) begin errors = errors + 1; $display("BLAD: rx=%h tx=%h", rx, pattern[i]); end
            if (edges != 8)        begin errors = errors + 1; $display("BLAD: %0d zboczy SCK", edges); end
            if (cs_n !== 1'b1)     begin errors = errors + 1; $display("BLAD: CS aktywny po transmisji"); end
            repeat (4) @(negedge clk);
        end
        if (errors == 0) $display("PASS: spi_master, 4 bajty w pętli zwrotnej, po 8 zboczy SCK");
        else             $display("FAIL: spi_master, %0d błędów", errors);
        $finish;
    end
endmodule
