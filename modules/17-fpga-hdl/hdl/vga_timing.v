`timescale 1ns/1ps
// Generator synchronizacji VGA 640 x 480 @ 60 Hz (zegar piksela ok. 25,175 MHz; w praktyce często 25 MHz).
// Linia: 640 widocznych + 16 (front porch) + 96 (synchronizacja) + 48 (back porch) = 800 pikseli.
// Ramka: 480 widocznych + 10 + 2 + 33 = 525 linii. Impulsy synchronizacji ujemne.
module vga_timing (
    input  wire       clk_pix,
    input  wire       rst,
    output reg  [9:0] x,          // numer piksela w linii
    output reg  [9:0] y,          // numer linii
    output wire       hsync,
    output wire       vsync,
    output wire       de          // obszar widoczny (data enable)
);
    localparam integer H_ACT = 640, H_FP = 16, H_SYNC = 96, H_TOT = 800;
    localparam integer V_ACT = 480, V_FP = 10, V_SYNC = 2,  V_TOT = 525;

    always @(posedge clk_pix) begin
        if (rst) begin
            x <= 0;
            y <= 0;
        end else if (x == H_TOT - 1) begin
            x <= 0;
            y <= (y == V_TOT - 1) ? 10'd0 : y + 1'b1;
        end else begin
            x <= x + 1'b1;
        end
    end

    assign de    = (x < H_ACT) && (y < V_ACT);
    assign hsync = ~((x >= H_ACT + H_FP) && (x < H_ACT + H_FP + H_SYNC));
    assign vsync = ~((y >= V_ACT + V_FP) && (y < V_ACT + V_FP + V_SYNC));
endmodule
