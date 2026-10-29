`timescale 1ns/1ps
// Odbiornik UART 8N1: synchronizator wejścia, wykrycie bitu startu,
// próbkowanie w środku każdego bitu, sprawdzenie bitu stopu.
module uart_rx #(
    parameter integer CLKS_PER_BIT = 434
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,        // asynchroniczne wejście z linii
    output reg  [7:0] data,
    output reg        valid      // impuls jednego taktu po odebraniu poprawnej ramki
);
    localparam [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg rx_s0 = 1'b1, rx_s1 = 1'b1;                          // synchronizator dwuprzerzutnikowy
    reg [1:0] state;
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_cnt;
    reg [2:0] bit_idx;
    reg [7:0] shreg;

    always @(posedge clk) begin
        rx_s0 <= rx;
        rx_s1 <= rx_s0;
        valid <= 1'b0;
        if (rst) begin
            state   <= IDLE;
            clk_cnt <= 0;
            bit_idx <= 0;
            shreg   <= 8'd0;
            data    <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (rx_s1 == 1'b0) state <= START;       // początek bitu startu
                end
                START: begin                                 // czekaj do środka bitu startu
                    if (clk_cnt == (CLKS_PER_BIT - 1) / 2) begin
                        clk_cnt <= 0;
                        state   <= (rx_s1 == 1'b0) ? DATA : IDLE;   // odrzuć krótkie zakłócenie
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                DATA: begin                                  // co CLKS_PER_BIT — środek kolejnego bitu
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt         <= 0;
                        shreg[bit_idx]  <= rx_s1;
                        if (bit_idx == 3'd7) state <= STOP;
                        else bit_idx <= bit_idx + 1'b1;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                STOP: begin
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= IDLE;
                        if (rx_s1 == 1'b1) begin             // poprawny bit stopu
                            data  <= shreg;
                            valid <= 1'b1;
                        end
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
            endcase
        end
    end
endmodule
