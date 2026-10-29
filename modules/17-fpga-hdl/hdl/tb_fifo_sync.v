`timescale 1ns/1ps
// Testbench: zapełnienie FIFO, próba zapisu do pełnego, odczyt w kolejności, próba odczytu z pustego.
module tb_fifo_sync;
    localparam integer DEPTH = 16;
    reg clk = 1'b0, rst = 1'b1, wr_en = 1'b0, rd_en = 1'b0;
    reg [7:0] din = 8'd0;
    wire [7:0] dout;
    wire full, empty;
    integer i, errors = 0;

    fifo_sync #(.W(8), .DEPTH(DEPTH)) dut (.clk(clk), .rst(rst), .wr_en(wr_en), .din(din), .full(full),
                                           .rd_en(rd_en), .dout(dout), .empty(empty));
    always #5 clk = ~clk;

    initial begin
        repeat (3) @(posedge clk);
        @(negedge clk) rst = 1'b0;
        @(negedge clk);
        if (!empty || full) begin errors = errors + 1; $display("BLAD: po resecie empty=%b full=%b", empty, full); end
        for (i = 0; i < DEPTH; i = i + 1) begin          // zapis DEPTH wartości
            wr_en = 1'b1; din = 8'h10 + i;
            @(negedge clk);
        end
        din = 8'hEE;                                       // zapis do pełnej kolejki — ma być zignorowany
        @(negedge clk);
        wr_en = 1'b0;
        if (!full) begin errors = errors + 1; $display("BLAD: brak flagi full"); end
        for (i = 0; i < DEPTH; i = i + 1) begin          // odczyt i sprawdzenie kolejności
            rd_en = 1'b1;
            @(negedge clk);
            if (dout !== 8'h10 + i) begin errors = errors + 1; $display("BLAD: odczyt %0d: %h", i, dout); end
        end
        @(negedge clk);                                    // odczyt z pustej — dout bez zmian
        rd_en = 1'b0;
        if (!empty) begin errors = errors + 1; $display("BLAD: brak flagi empty"); end
        if (dout !== 8'h10 + DEPTH - 1) begin errors = errors + 1; $display("BLAD: dout zmienione przy pustej: %h", dout); end
        if (errors == 0) $display("PASS: fifo_sync, %0d zapisów i odczytów w poprawnej kolejności", DEPTH);
        else             $display("FAIL: fifo_sync, %0d błędów", errors);
        $finish;
    end
endmodule
