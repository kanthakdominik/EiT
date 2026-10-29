`timescale 1ns/1ps
// Testbench: nadajnik połączony z odbiornikiem (pętla zwrotna), kilka bajtów,
// porównanie odebranych danych z wysłanymi.
module tb_uart;
    localparam integer CPB = 16;            // małe CLKS_PER_BIT — krótka symulacja
    localparam integer NBYTES = 6;
    reg clk = 1'b0;
    reg rst = 1'b1;
    reg start = 1'b0;
    reg [7:0] din = 8'd0;
    wire tx, busy, valid;
    wire [7:0] dout;
    reg [7:0] expected [0:NBYTES-1];
    integer errors = 0, received = 0, i;

    uart_tx #(.CLKS_PER_BIT(CPB)) utx (.clk(clk), .rst(rst), .start(start), .data(din), .tx(tx), .busy(busy));
    uart_rx #(.CLKS_PER_BIT(CPB)) urx (.clk(clk), .rst(rst), .rx(tx), .data(dout), .valid(valid));

    always #10 clk = ~clk;                  // 50 MHz

    always @(negedge clk) begin             // sprawdzanie w połowie okresu — bez wyścigów
        if (valid) begin
            if (dout !== expected[received]) begin
                errors = errors + 1;
                $display("BLAD: odebrano %h, oczekiwano %h", dout, expected[received]);
            end
            received = received + 1;
        end
    end

    initial begin
        expected[0] = 8'h55; expected[1] = 8'hA3; expected[2] = 8'h00;
        expected[3] = 8'hFF; expected[4] = 8'h0F; expected[5] = 8'h81;
        repeat (5) @(posedge clk);
        @(negedge clk) rst = 1'b0;
        for (i = 0; i < NBYTES; i = i + 1) begin
            @(negedge clk) begin din = expected[i]; start = 1'b1; end
            @(negedge clk) start = 1'b0;
            @(negedge clk);
            wait (!busy);
            repeat (2*CPB) @(negedge clk);  // przerwa między ramkami
        end
        repeat (4*CPB) @(negedge clk);
        if (errors == 0 && received == NBYTES)
            $display("PASS: uart_tx -> uart_rx, odebrano %0d bajtów bez błędów", received);
        else
            $display("FAIL: uart, bledy=%0d, odebrano=%0d z %0d", errors, received, NBYTES);
        $finish;
    end
endmodule
