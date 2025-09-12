
module Uso_del_PLL_IP_core (
    input  logic clk100,   // Reloj externo 100 MHz (Nexys-4)
    input  logic rst,      // Reset activo alto (botón)
    output logic led       // LED de verificación
);

    // --- Señales internas del PLL ---
    (* MARK_DEBUG="TRUE" *) logic clk10;   // Reloj generado de 10 MHz
    (* MARK_DEBUG="TRUE" *) logic locked;  // '1' cuando el PLL está estable

    // --- Reset sincronizado para el dominio clk10 ---
    logic [1:0] rst_sync_clk10;
    logic       rst_clk10;

    // --- Instancia del Clocking Wizard (PLL) ---
    // Configurado para: clk_in1 = 100 MHz  -> clk_out1 = 10 MHz
    clk_wiz_1 pll_inst (
       .clk_in1 (clk100),
       .reset   (rst),       // Reset activo alto del IP
       .clk_out1(clk10),
       .locked  (locked)
    );

    // --- Sincronizador de reset en dominio clk10 ---
    always_ff @(posedge clk10 or posedge rst) begin
        if (rst) begin
            rst_sync_clk10 <= 2'b11;
        end else begin
            // Mantener en reset hasta que 'locked' sea 1
            rst_sync_clk10 <= {rst_sync_clk10[0], ~locked};
        end
    end
    assign rst_clk10 = rst_sync_clk10[1];

    // --- Contador para ver actividad con el reloj de 10 MHz ---
    (* MARK_DEBUG="TRUE" *) logic [23:0] counter;
    always_ff @(posedge clk10) begin
        if (rst_clk10) counter <= 24'd0;
        else           counter <= counter + 1'b1;
    end

    // LED 
    assign led = counter[23];
    
endmodule
