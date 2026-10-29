`timescale 1ns/1ps
// Filtr FIR 5. rzędu w potoku: h = [1 4 6 4 1] / 16 (filtr dolnoprzepustowy, wzmocnienie DC = 1).
// Opóźnienie: wynik dla próbki wejściowej pojawia się na wyjściu po 4 taktach.
module fir5 (
    input  wire               clk,
    input  wire               rst,
    input  wire signed [11:0] x,
    output reg  signed [15:0] y
);
    reg signed [11:0] d0, d1, d2, d3, d4;          // linia opóźniająca
    reg signed [15:0] p0, p1, p2, p3, p4;          // stopień 1: iloczyny
    reg signed [17:0] s01, s23, s4;                // stopień 2: sumy częściowe
    reg signed [17:0] s;                           // stopień 3: suma

    always @(posedge clk) begin
        if (rst) begin
            d0 <= 0; d1 <= 0; d2 <= 0; d3 <= 0; d4 <= 0;
            p0 <= 0; p1 <= 0; p2 <= 0; p3 <= 0; p4 <= 0;
            s01 <= 0; s23 <= 0; s4 <= 0; s <= 0; y <= 0;
        end else begin
            d0 <= x;  d1 <= d0; d2 <= d1; d3 <= d2; d4 <= d3;
            p0 <= d0; p1 <= d1 * 4; p2 <= d2 * 6; p3 <= d3 * 4; p4 <= d4;
            s01 <= p0 + p1; s23 <= p2 + p3; s4 <= p4;
            s   <= s01 + s23 + s4;
            y   <= s >>> 4;                        // dzielenie przez 16 (przesunięcie arytmetyczne)
        end
    end
endmodule
