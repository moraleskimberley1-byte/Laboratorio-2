module btn_pulse(
    input  logic clk,        // 100 MHz
    input  logic rst,
    input  logic btn_in,     // asíncrono desde pin
    output logic pulse       // 1 ciclo por toque
);
    // Sincronizador
    logic b_sync0, b_sync1;
    always_ff @(posedge clk) begin
        b_sync0 <= btn_in;
        b_sync1 <= b_sync0;
    end

    // Debounce ~10 ms @100 MHz
    localparam int CNT_MAX = 1_000_000; // 10 ms
    logic [$clog2(CNT_MAX):0] cnt;
    logic b_stable, b_prev;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt     <= '0;
            b_stable<= 1'b0;
            b_prev  <= 1'b0;
            pulse   <= 1'b0;
        end else begin
            if (b_sync1 == b_stable) begin
                cnt <= '0;
            end else if (cnt == CNT_MAX) begin
                b_stable <= b_sync1; // acepta nuevo estado estable
                cnt      <= '0;
            end else begin
                cnt <= cnt + 1'b1;
            end

            // Detector de flanco ascendente
            pulse <= (b_stable & ~b_prev);
            b_prev<= b_stable;
        end
    end
endmodule
