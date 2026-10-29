`timescale 1ns/1ps
// Nadajnik UART 8N1. CLKS_PER_BIT = f_clk / baud (np. 50 MHz / 115200 ≈ 434).
module uart_tx #(
    parameter integer CLKS_PER_BIT = 434
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,     // impuls jednego taktu rozpoczyna wysyłanie
    input  wire [7:0] data,
    output reg        tx,
    output wire       busy
);
    localparam [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

    reg [1:0] state;
    reg [$clog2(CLKS_PER_BIT)-1:0] clk_cnt;
    reg [2:0] bit_idx;
    reg [7:0] shreg;

    assign busy = (state != IDLE);

    always @(posedge clk) begin
        if (rst) begin
            state   <= IDLE;
            tx      <= 1'b1;
            clk_cnt <= 0;
            bit_idx <= 0;
            shreg   <= 8'd0;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1'b1;
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    if (start) begin
                        shreg <= data;
                        state <= START;
                    end
                end
                START: begin
                    tx <= 1'b0;                              // bit startu
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= DATA;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                DATA: begin
                    tx <= shreg[bit_idx];                    // LSB pierwszy
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 3'd7) state <= STOP;
                        else bit_idx <= bit_idx + 1'b1;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
                STOP: begin
                    tx <= 1'b1;                              // bit stopu
                    if (clk_cnt == CLKS_PER_BIT - 1) begin
                        clk_cnt <= 0;
                        state   <= IDLE;
                    end else clk_cnt <= clk_cnt + 1'b1;
                end
            endcase
        end
    end
endmodule
