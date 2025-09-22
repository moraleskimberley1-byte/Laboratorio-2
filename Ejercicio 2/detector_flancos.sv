module detector_flancos (
    input  logic clk,
    input  logic rst_n,
    input  logic signal_in,
    output logic flanco_positivo,
    output logic flanco_negativo
);

    logic signal_reg;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            signal_reg <= 1'b0;
        end else begin
            signal_reg <= signal_in;
        end
    end
    
    assign flanco_positivo = signal_in & ~signal_reg;
    assign flanco_negativo = ~signal_in & signal_reg;

endmodule