`timescale 1ns/1ps
// Master SPI, tryb 0 (CPOL = 0, CPHA = 0), 8 bitów, MSB pierwszy.
// f_SCK = f_clk / (2 * CLK_DIV). MISO próbkowane na zboczu narastającym SCK,
// MOSI zmieniane na zboczu opadającym.
module spi_master #(
    parameter integer CLK_DIV = 4            // co najmniej 2
) (
    input  wire       clk,
    input  wire       rst,
    input  wire       start,
    input  wire [7:0] tx_data,
    output reg  [7:0] rx_data,
    output reg        done,                  // impuls po zakończeniu transmisji
    output reg        busy,
    output reg        sck,
    output reg        mosi,
    input  wire       miso,
    output reg        cs_n
);
    reg [$clog2(CLK_DIV)-1:0] div;
    reg [2:0] bit_cnt;
    reg [7:0] shreg_tx, shreg_rx;

    always @(posedge clk) begin
        done <= 1'b0;
        if (rst) begin
            busy <= 1'b0; sck <= 1'b0; cs_n <= 1'b1; mosi <= 1'b0;
            div <= 0; bit_cnt <= 0; rx_data <= 8'd0; shreg_tx <= 8'd0; shreg_rx <= 8'd0;
        end else if (!busy) begin
            sck <= 1'b0;
            if (start) begin
                busy     <= 1'b1;
                cs_n     <= 1'b0;
                shreg_tx <= tx_data;
                mosi     <= tx_data[7];          // pierwszy bit gotowy przed pierwszym zboczem SCK
                bit_cnt  <= 3'd7;
                div      <= 0;
            end
        end else if (div == CLK_DIV - 1) begin
            div <= 0;
            if (!sck) begin                      // zbocze narastające SCK: próbkuj MISO
                sck      <= 1'b1;
                shreg_rx <= {shreg_rx[6:0], miso};
            end else begin                       // zbocze opadające SCK: następny bit lub koniec
                sck <= 1'b0;
                if (bit_cnt == 3'd0) begin
                    busy    <= 1'b0;
                    cs_n    <= 1'b1;
                    done    <= 1'b1;
                    rx_data <= shreg_rx;
                end else begin
                    bit_cnt  <= bit_cnt - 1'b1;
                    shreg_tx <= {shreg_tx[6:0], 1'b0};
                    mosi     <= shreg_tx[6];
                end
            end
        end else begin
            div <= div + 1'b1;
        end
    end
endmodule
