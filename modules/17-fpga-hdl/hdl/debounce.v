`timescale 1ns/1ps
// Eliminacja drgań styków: synchronizator dwuprzerzutnikowy + licznik stabilności.
// Wyjście zmienia stan dopiero, gdy wejście jest stabilne przez N kolejnych taktów.
module debounce #(
    parameter integer N = 16
) (
    input  wire clk,
    input  wire rst,
    input  wire btn_in,    // sygnał asynchroniczny z przycisku
    output reg  btn_out
);
    reg s0, s1;                          // synchronizator (CDC, temat 06)
    reg [$clog2(N+1)-1:0] cnt;

    always @(posedge clk) begin
        s0 <= btn_in;
        s1 <= s0;
        if (rst) begin
            cnt     <= 0;
            btn_out <= 1'b0;
        end else if (s1 == btn_out) begin
            cnt <= 0;                    // brak zmiany — licznik od nowa
        end else if (cnt == N - 1) begin
            btn_out <= s1;               // nowy stan stabilny przez N taktów
            cnt     <= 0;
        end else begin
            cnt <= cnt + 1'b1;
        end
    end
endmodule
