module lfsr16 (
    input  logic       clk,
    input  logic       rst,        // activo alto (ajusta si tu reset es distinto)
    input  logic       en,         // avanza 1 paso cuando en=1
    input  logic [15:0]seed,       // no cero
    output logic [15:0]q
);
    wire fb = q[15] ^ q[13] ^ q[12] ^ q[10]; // x^16 + x^14 + x^13 + x^11 + 1
    always_ff @(posedge clk) begin
        if (rst)
            q <= (seed != 16'h0000) ? seed : 16'h1ACE;
        else if (en)
            q <= {q[14:0], fb};
    end
endmodule
