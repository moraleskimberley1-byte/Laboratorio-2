
`timescale 1ns/1ps

// Testbench para el módulo top_p3
// Este testbench simula el funcionamiento del sistema completo, incluyendo el registro y el display multiplexado.
// Se generan estímulos para probar el registro y observar cómo se visualizan los datos en el display.
//
// Explicación detallada:
// 1. Se genera un reloj de 100 MHz usando always #5 clk = ~clk.
// 2. Se inicializan los switches y señales de control.
// 3. Se instancia el módulo top_p3 como DUT (Device Under Test).
// 4. En el bloque initial:
//    - Se aplica reset durante algunos ciclos de reloj para inicializar el sistema.
//    - Se carga el valor 0xBEEF en los switches y se activa el write enable para almacenar ese valor en el registro.
//    - Se desactiva el write enable y se deja correr la simulación para observar el multiplexado del display.
//    - Finalmente, se termina la simulación.
// Este testbench permite verificar que el registro almacena correctamente el dato y que el display muestra el valor esperado.
module tb_top_p3;
    logic clk=0;
    // Generador de reloj: alterna el valor de clk cada 5 ns para obtener 100 MHz
    always #5 clk = ~clk; // 100 MHz

    // Señales de entrada para el DUT (Device Under Test)
    logic [15:0] SW = 16'h1234; // Valor inicial de los switches
    logic SW_RST = 1'b1;        // Reset activo al inicio
    logic SW_WE  = 1'b0;        // Write enable desactivado al inicio
    // Señales de salida del DUT
    logic [7:0] AN;
    logic [6:0] SEG;
    logic DP;

    // Instancia del módulo top_p3
    top_p3 dut(
        .CLK100MHZ(clk), .SW(SW),
        .SW_RST(SW_RST), .SW_WE(SW_WE),
        .AN(AN), .SEG(SEG), .DP(DP)
    );

    initial begin
        // Se aplica reset durante 5 ciclos de reloj para inicializar el registro
        repeat(5) @(posedge clk);
        SW_RST = 0; // Se desactiva el reset

        // Se carga el valor 0xBEEF en los switches y se activa el write enable
        // Esto simula que el usuario presiona el switch de WE para almacenar el dato en el registro
        SW      = 16'hBEEF;
        SW_WE   = 1;  @(posedge clk); // Se almacena el dato en el registro
        SW_WE   = 0;                  // Se desactiva el write enable

        // Se deja correr la simulación para observar el multiplexado del display
        // El display debería mostrar el valor almacenado en el registro
        #(2000*1ns);

    end
endmodule

