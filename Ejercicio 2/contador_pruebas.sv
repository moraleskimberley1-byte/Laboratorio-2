module contador_pruebas #(
    parameter WIDTH = 8
)(
    input  logic clk,
    input  logic rst,
    input  logic EN,
    output logic [WIDTH-1:0] count
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= '0;
        end else if (EN) begin  // Simplificado: usar EN directamente
            count <= count + 1;
        end
    end

endmodule