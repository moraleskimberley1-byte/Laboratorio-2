module tick_hz #(
    parameter int HZ = 0.5    // 200 Hz = pulso cada 5 ms
)(
    input  logic clk,         // 100 MHz
    input  logic rst,         // activo alto
    output logic tick         // 1 ciclo a HZ
);
    localparam int N = (100_000_000 / HZ) - 1;
    localparam int W = $clog2(N+1);
    logic [W-1:0] cnt;
    always_ff @(posedge clk) begin
        if (rst) begin cnt <= '0; tick <= 1'b0;
        end else if (cnt == N) begin cnt <= '0; tick <= 1'b1;
        end else begin cnt <= cnt + 1'b1; tick <= 1'b0; end
    end
endmodule
