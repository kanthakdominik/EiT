`timescale 1ns/1ps
// Licznik dzielący zegar: dioda zmienia stan z częstotliwością 2*BLINK_HZ (miga z BLINK_HZ).
module blink #(
    parameter integer CLK_HZ   = 50_000_000,
    parameter integer BLINK_HZ = 1
) (
    input  wire clk,
    input  wire rst,      // reset synchroniczny, aktywny wysoki
    output reg  led
);
    localparam integer HALF = CLK_HZ / (2 * BLINK_HZ);
    localparam integer W    = $clog2(HALF);

    reg [W-1:0] cnt;

    always @(posedge clk) begin
        if (rst) begin
            cnt <= 0;
            led <= 1'b0;
        end else if (cnt == HALF - 1) begin
            cnt <= 0;
            led <= ~led;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
