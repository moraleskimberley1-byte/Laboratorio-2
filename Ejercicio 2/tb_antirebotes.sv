`timescale 1ns/1ps

module tb_antirebotes;

    // Señales del testbench
    logic clk_100mhz = 0;
    logic rst_n = 0;
    logic btn_test = 0;
    logic [15:0] leds;
    
    // DUT (Device Under Test)
    top_antirebotes dut (
        .clk_100mhz(clk_100mhz),
        .rst_n(rst_n),
        .btn_test(btn_test),
        .leds(leds)
    );
    
    // Generador de reloj 100MHz (periodo = 10ns)
    always #5 clk_100mhz = ~clk_100mhz;
    
    // Periodo del reloj de 10MHz = 100ns (10 ciclos de 100MHz)
    // Para antirebotes con 4 bits = 16 ciclos de 10MHz = 1600ns
    
    // Task para simular rebotes realistas
    task simulate_bouncy_press(input int bounce_cycles, input int stable_time_ns);
        integer i;
        begin
            $display("T=%0t: Iniciando pulso con %0d rebotes", $time, bounce_cycles);
            
            // Simular rebotes al presionar
            for (i = 0; i < bounce_cycles; i++) begin
                btn_test = 1;
                #($urandom_range(20, 80));  // Rebote aleatorio 20-80ns
                btn_test = 0;
                #($urandom_range(10, 50));  // Pausa aleatoria 10-50ns
            end
            
            // Señal estable (presionado)
            btn_test = 1;
            #stable_time_ns;
            
            // Simular rebotes al soltar
            for (i = 0; i < bounce_cycles/2; i++) begin
                btn_test = 0;
                #($urandom_range(20, 60));
                btn_test = 1;
                #($urandom_range(10, 30));
            end
            
            // Señal estable (soltado)
            btn_test = 0;
            
            $display("T=%0t: Pulso completado", $time);
        end
    endtask
    
    // Task para pulso limpio (sin rebotes)
    task simulate_clean_press(input int hold_time_ns);
        begin
            $display("T=%0t: Iniciando pulso limpio", $time);
            btn_test = 1;
            #hold_time_ns;
            btn_test = 0;
            $display("T=%0t: Pulso limpio completado", $time);
        end
    endtask
    
    // Proceso principal de estímulos
    initial begin
        $display("=== INICIO SIMULACION ANTIREBOTES EJERCICIO 2 ===");
        $display("Configuracion: COUNTER_BITS=%0d, Tiempo antirebotes=%0d ciclos de 10MHz", 
                 4, 2**4);
        $display("Tiempo antirebotes = %0d ns", 2**4 * 100);
        
        // Reset inicial
        rst_n = 0;
        btn_test = 0;
        #500;  // 500ns
        
        rst_n = 1;
        #1000; // Esperar estabilización
        
        $display("T=%0t: Reset completado, contador inicial=%d", $time, leds[7:0]);
        
        // === PRUEBA 1: Pulso con muchos rebotes ===
        #2000; // Espacio entre pruebas
        simulate_bouncy_press(.bounce_cycles(8), .stable_time_ns(5000));
        #3000; // Esperar procesamiento completo
        $display("T=%0t: Después de pulso con rebotes 1, contador=%d", $time, leds[7:0]);
        
        // === PRUEBA 2: Pulso limpio ===
        #2000;
        simulate_clean_press(.hold_time_ns(3000));
        #3000;
        $display("T=%0t: Después de pulso limpio, contador=%d", $time, leds[7:0]);
        
        // === PRUEBA 3: Pulso con rebotes diferentes ===
        #2000;
        simulate_bouncy_press(.bounce_cycles(5), .stable_time_ns(4000));
        #3000;
        $display("T=%0t: Después de pulso con rebotes 2, contador=%d", $time, leds[7:0]);
        
        // === PRUEBA 4: Pulso muy corto (debería ser ignorado) ===
        #2000;
        $display("T=%0t: Prueba pulso muy corto (debe ser ignorado)", $time);
        btn_test = 1;
        #200;  // Solo 200ns, menor que tiempo antirebotes
        btn_test = 0;
        #3000;
        $display("T=%0t: Después de pulso corto, contador=%d", $time, leds[7:0]);
        
        // === PRUEBA 5: Dos pulsos rápidos ===
        #2000;
        $display("T=%0t: Prueba dos pulsos rápidos", $time);
        simulate_clean_press(.hold_time_ns(2000));
        #1000;  // Pausa corta
        simulate_clean_press(.hold_time_ns(2000));
        #3000;
        $display("T=%0t: Después de pulsos rápidos, contador=%d", $time, leds[7:0]);
        
        // Esperar procesamiento final
        #5000;
        
        // === RESULTADOS FINALES ===
        $display("=== RESUMEN FINAL ===");
        $display("Contador final: %d", leds[7:0]);
        $display("Pruebas realizadas:");
        $display("  1. Pulso con rebotes -> Debe incrementar");
        $display("  2. Pulso limpio -> Debe incrementar");  
        $display("  3. Pulso con rebotes -> Debe incrementar");
        $display("  4. Pulso muy corto -> NO debe incrementar");
        $display("  5. Dos pulsos rapidos -> Deben incrementar");
        $display("Esperado: 5 incrementos, Obtenido: %d", leds[7:0]);
        
        if (leds[7:0] == 8'd5) begin
            $display("*** PRUEBA EXITOSA: Sistema antirebotes funciona correctamente ***");
        end else begin
            $display("*** RESULTADO: %d pulsos detectados de 5 esperados ***", leds[7:0]);
            if (leds[7:0] >= 8'd3) begin
                $display("*** PARCIALMENTE EXITOSO: Al menos detecta pulsos válidos ***");
            end else begin
                $display("*** REVISAR: Muy pocos pulsos detectados ***");
            end
        end
        
        $finish;
    end
    
    // Monitor para cambios en el contador - MAS DETALLADO
    always @(leds[7:0]) begin
        if ($time > 0) begin
            $display("*** T=%0t: CONTADOR CAMBIO A %d ***", $time, leds[7:0]);
        end
    end
    
    // Monitor para señales internas críticas
    always @(posedge dut.clk_10mhz) begin
        if (dut.btn_edge) begin
            $display(">>> T=%0t: FLANCO POSITIVO DETECTADO en btn_clean <<<", $time);
        end
    end
    
    // Monitor para señal limpia del antirebotes
    always @(dut.btn_clean) begin
        $display("    T=%0t: btn_clean cambio a %b", $time, dut.btn_clean);
    end
    
    // Monitor del reloj generado
    initial begin
        wait(rst_n);
        @(posedge dut.clk_10mhz);
        $display("T=%0t: Primer flanco de clk_10mhz detectado - Reloj funcionando", $time);
    end
    
    // Timeout de seguridad más largo
    initial begin
        #200000;  // 200 microsegundos
        $display("*** TIMEOUT: Simulación terminada por límite de tiempo ***");
        $finish;
    end

endmodule