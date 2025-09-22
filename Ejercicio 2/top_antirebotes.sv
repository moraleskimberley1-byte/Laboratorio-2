module top_antirebotes (
    input  logic clk_100mhz,
    input  logic rst_n,
    input  logic btn_test,
    output logic [15:0] leds
);

    // Señales internas
    logic clk_10mhz;
    logic rst_pos;
    logic btn_sync;
    logic btn_clean;
    logic btn_edge;
    logic [7:0] count_value;
    
    assign rst_pos = ~rst_n;
    
    // Generar reloj de 10MHz
    clk_generator clk_gen (
        .clk_100mhz(clk_100mhz),
        .rst_n(rst_n),
        .clk_10mhz(clk_10mhz)
    );
    
    // Sincronizar entrada
    sincronizador #(.STAGES(2)) sync_btn (
        .clk(clk_10mhz),
        .rst_n(rst_n),
        .async_in(btn_test),
        .sync_out(btn_sync)
    );
    
    // Eliminar rebotes - REDUCIDO PARA SIMULACIÓN
    // Para síntesis real, cambiar a .COUNTER_BITS(16) o más
    antirebotes #(.COUNTER_BITS(4)) debouncer (  // 4 bits = 16 ciclos para simulación
        .clk(clk_10mhz),
        .rst_n(rst_n),
        .button_in(btn_sync),
        .button_clean(btn_clean)
    );
    
    // Detectar flancos
    detector_flancos edge_detector (
        .clk(clk_10mhz),
        .rst_n(rst_n),
        .signal_in(btn_clean),
        .flanco_positivo(btn_edge),
        .flanco_negativo()
    );
    
    // Contador de pruebas
    contador_pruebas #(.WIDTH(8)) counter (
        .clk(clk_10mhz),
        .rst(rst_pos),
        .EN(btn_edge),
        .count(count_value)
    );
    
    // Salida a LEDs
    assign leds[7:0] = count_value;
    assign leds[15:8] = 8'b0;

endmodule