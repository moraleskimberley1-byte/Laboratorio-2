module sincronizador #(
    parameter STAGES = 2
)(
    input  logic clk,
    input  logic rst_n,
    input  logic async_in,
    output logic sync_out
);

    logic [STAGES-1:0] sync_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sync_reg <= '0;
        end else begin
            sync_reg <= {sync_reg[STAGES-2:0], async_in};
        end
    end
    
    assign sync_out = sync_reg[STAGES-1];

endmodule