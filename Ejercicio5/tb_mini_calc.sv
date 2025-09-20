// tb_mini_calc.sv
`timescale 1ns/1ps

module tb_mini_calc;
  // 1) Reloj real de simulación (100 MHz, 10 ns)
  localparam int SIM_CLK_HZ = 100_000_000;

  // 2) Escala de tiempos dentro del DUT para que "1 segundo lógico" sea ~1 ms en sim.
  //    (Si quieres aún más rápido, baja a 10_000).
  localparam int DUT_CLK_HZ = 100_000;

  // Señales del top
  logic clk, rst;
  logic [15:0] SW;
  logic [3:0]  BTN;
  logic [15:0] LED;
  logic [6:0]  SEG;
  logic        DP;
  logic [7:0]  AN;

  // Instancia del DUT: solo sobrescribimos CLK_HZ para acelerar la sim
  mini_calc_top #(.CLK_HZ(DUT_CLK_HZ)) dut (
    .CLK100MHZ(clk),
    .RESET(rst),
    .SW(SW),
    .BTN(BTN),
    .LED(LED),
    .SEG(SEG),
    .DP(DP),
    .AN(AN)
  );

  // Generación de reloj (100 MHz)
  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // Formato de tiempo legible
  initial $timeformat(-6, 3, " us", 10);

  // Tarea: pulsar botón con duración suficiente para el debouncer (~1 ms lógico)
  task automatic press_btn(input int idx);
    begin
      BTN[idx] = 1'b1;
      // Deja el botón "alto" durante 1000 ciclos de clk (10 us de sim)
      repeat (1000) @(posedge clk);
      BTN[idx] = 1'b0;
      repeat (100) @(posedge clk);
    end
  endtask

  // 3) Estímulos que cubren un ciclo completo y el modo recorrido
  initial begin
    // Reset y estado inicial
    rst = 1'b1;  SW = '0; BTN = '0;
    repeat (10) @(posedge clk);
    rst = 1'b0;

    // Dejar que la FSM capture y muestre A (~2 s lógicos ≈ 2 ms sim)
    // y luego B (~2 ms sim). Damos margen holgado.
    #(6_000_000); // 6 ms

    // Operación ADD (BTN[0])
    $display("[%t] ADD", $realtime);
    press_btn(0);

    // Espera a que muestre/almacene R (~1 ms sim) con margen
    #(3_000_000);

    // Operación SUB (BTN[1])
    $display("[%t] SUB", $realtime);
    press_btn(1);

    #(3_000_000);

    // Entrar a modo recorrido y permanecer unos ms
    $display("[%t] Entrar RECORRIDO (SW0=1)", $realtime);
    SW[0] = 1'b1;
    #(5_000_000);

    // Volver a cálculo
    $display("[%t] Salir RECORRIDO (SW0=0)", $realtime);
    SW[0] = 1'b0;
    #(5_000_000);

    $display("[%t] FIN de la prueba", $realtime);
    $finish;
  end

  // 4) Checados básicos acordes al enunciado (no intrusivos)
  //    a) Punto decimal siempre apagado (activo-bajo)
  always @(posedge clk) begin
    assert (DP === 1'b1)
      else $error("[%t] DP no apagado (esperado 1'b1 activo-bajo)", $realtime);
  end

  //    b) Multiplexado correcto: a lo sumo un ánodo de los 4 bajos a la vez
  function automatic int count_zeros4(input logic [3:0] v);
    count_zeros4 = (v[0]==1'b0) + (v[1]==1'b0) + (v[2]==1'b0) + (v[3]==1'b0);
  endfunction
  always @(posedge clk) begin
    int nlow = count_zeros4(AN[3:0]);
    assert (nlow <= 1)
      else $error("[%t] Multiplexado inválido: AN=%b (más de un dígito activo)", $realtime, AN[3:0]);
  end

  // 5) Volcado opcional para GTKWave/iverilog (xsim lo ignora sin problema)
  initial begin
    $dumpfile("tb_mini_calc.vcd");
    $dumpvars(0, tb_mini_calc);
  end

endmodule
