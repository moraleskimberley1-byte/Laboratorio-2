// regfile.sv
// Banco de registros parametrizable
// - Cantidad de registros = 2^N
// - Ancho de palabra = W
// - 2 puertos de lectura combinacional (rs1, rs2)
// - 1 puerto de escritura sincrónica (we, addr_rd, data_in)
// - El registro 0 (x0) es de solo lectura y siempre entrega 0
// Recomendación: usar reset síncrono y un único dominio de reloj.

module regfile #(
    parameter int N = 4,   // -> 2^N registros
    parameter int W = 16   // ancho de palabra
)(
    input  logic             clk,
    input  logic             rst,        // reset síncrono, activo alto
    input  logic             we,         // write enable
    input  logic [N-1:0]     addr_rd,    // dirección de escritura
    input  logic [N-1:0]     addr_rs1,   // dirección lectura 1
    input  logic [N-1:0]     addr_rs2,   // dirección lectura 2
    input  logic [W-1:0]     data_in,    // dato a escribir
    output logic [W-1:0]     rs1,        // salida lectura 1
    output logic [W-1:0]     rs2         // salida lectura 2
);
    // Profundidad del banco
    localparam int DEPTH = (1 << N);

    // Matriz de registros
    logic [W-1:0] regs [0:DEPTH-1];

    // --- Escritura sincrónica + reset síncrono ---
    always_ff @(posedge clk) begin
        if (rst) begin
            // Limpia todos los registros
            for (int i = 0; i < DEPTH; i++) begin
                regs[i] <= '0;
            end
        end else if (we && (addr_rd != '0)) begin
            // x0 (índice 0) es solo lectura: no se escribe
            regs[addr_rd] <= data_in;
        end
    end

    // --- Lecturas combinacionales ---
    // x0 siempre entrega 0
    assign rs1 = (addr_rs1 == '0) ? '0 : regs[addr_rs1];
    assign rs2 = (addr_rs2 == '0) ? '0 : regs[addr_rs2];

endmodule
