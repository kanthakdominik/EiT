`timescale 1ns/1ps
// Testbench: porównanie wyjścia potokowego filtru FIR z modelem behawioralnym
// (ta sama suma ważona liczona w testbenchu), z uwzględnieniem opóźnienia potoku.
module tb_fir5;
    localparam integer N = 60;
    reg clk = 1'b0, rst = 1'b1;
    reg  signed [11:0] x = 12'sd0;
    wire signed [15:0] y;
    reg  signed [11:0] in_mem [0:N-1];
    integer m, errors = 0, checks = 0, seed = 1, v;

    fir5 dut (.clk(clk), .rst(rst), .x(x), .y(y));
    always #5 clk = ~clk;

    function integer sample(input integer k);      // wejście z zerami przed początkiem
        sample = (k >= 0 && k < N) ? in_mem[k] : 0;
    endfunction

    function integer model(input integer j);       // y(j) = (x(j) + 4x(j-1) + 6x(j-2) + 4x(j-3) + x(j-4)) / 16
        model = (sample(j) + 4*sample(j-1) + 6*sample(j-2) + 4*sample(j-3) + sample(j-4)) >>> 4;
    endfunction

    initial begin
        for (m = 0; m < N; m = m + 1) begin
            if (m < 10)      in_mem[m] = 12'sd1000;        // skok dodatni
            else if (m < 20) in_mem[m] = -12'sd1000;       // skok ujemny
            else begin
                v = $random(seed) % 2048;                   // -2047 … 2047
                in_mem[m] = v;
            end
        end
        repeat (3) @(posedge clk);
        @(negedge clk) rst = 1'b0;
        for (m = 0; m < N + 6; m = m + 1) begin
            @(negedge clk);
            if (m >= 5 && m - 5 < N) begin                  // opóźnienie: wynik dla x(m-5) widoczny teraz
                checks = checks + 1;
                if (y != model(m - 5)) begin
                    errors = errors + 1;
                    $display("BLAD: m=%0d y=%0d model=%0d", m, y, model(m - 5));
                end
            end
            x = (m < N) ? in_mem[m] : 12'sd0;
        end
        if (errors == 0 && checks == N) $display("PASS: fir5, %0d próbek zgodnych z modelem", checks);
        else                            $display("FAIL: fir5, %0d błędów na %0d porównań", errors, checks);
        $finish;
    end
endmodule
