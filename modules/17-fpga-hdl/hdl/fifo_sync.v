`timescale 1ns/1ps
// Kolejka FIFO z jednym zegarem. Wskaźniki mają dodatkowy bit, który odróżnia
// stan „pełny” (te same adresy, różne bity najstarsze) od „pusty” (wskaźniki równe).
module fifo_sync #(
    parameter integer W     = 8,
    parameter integer DEPTH = 16          // potęga dwójki
) (
    input  wire         clk,
    input  wire         rst,
    input  wire         wr_en,
    input  wire [W-1:0] din,
    output wire         full,
    input  wire         rd_en,
    output reg  [W-1:0] dout,             // dane dostępne w takcie po rd_en
    output wire         empty
);
    localparam integer AW = $clog2(DEPTH);

    reg [W-1:0] mem [0:DEPTH-1];
    reg [AW:0]  wptr, rptr;

    assign empty = (wptr == rptr);
    assign full  = (wptr[AW-1:0] == rptr[AW-1:0]) && (wptr[AW] != rptr[AW]);

    always @(posedge clk) begin
        if (rst) begin
            wptr <= 0;
            rptr <= 0;
            dout <= 0;
        end else begin
            if (wr_en && !full) begin
                mem[wptr[AW-1:0]] <= din;
                wptr <= wptr + 1'b1;
            end
            if (rd_en && !empty) begin
                dout <= mem[rptr[AW-1:0]];
                rptr <= rptr + 1'b1;
            end
        end
    end
endmodule
