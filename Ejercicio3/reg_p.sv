
// Módulo de registro parametrizable
// Permite almacenar un dato de ancho configurable (por defecto 16 bits)
// El registro se actualiza en flanco positivo de clk
// Si rst está activo, el registro se pone en cero
// Si we (write enable) está activo, el registro toma el valor de d
module reg_p #(
    parameter int WIDTH = 16 // Ancho del registro (bits)
) (
    input  logic                 clk,  // Reloj
    input  logic                 rst,  // Reset asíncrono
    input  logic                 we,   // Habilitador de escritura
    input  logic [WIDTH-1:0]     d,    // Dato de entrada
    output logic [WIDTH-1:0]     q     // Dato almacenado (salida)
);
    // Proceso secuencial: actualiza el registro en el flanco positivo del reloj
    always_ff @(posedge clk) begin
        if (rst)       q <= '0;   // Si hay reset, el registro se pone en cero
        else if (we)   q <= d;    // Si write enable está activo, almacena el dato de entrada
        // Si we no está activo, mantiene el valor anterior
    end
endmodule