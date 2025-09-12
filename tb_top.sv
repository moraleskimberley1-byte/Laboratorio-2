`timescale 1ns/1ps
module tb_top;
  timeunit 1ns; timeprecision 1ps;

  // Señales TB
  logic clk100 = 0;
  logic rst    = 1;
  wire  led;

  // Variables/estímulos
  real  t0, per_ns;
  int   samples_ok;
  int   cycles100;
  int   i;

  // DUT
  Uso_del_PLL_IP_core dut (
    .clk100(clk100),
    .rst   (rst),
    .led   (led)
  );

  // 100 MHz (T = 10 ns)
  always #5 clk100 = ~clk100;

  // Mide un periodo de clk10 en ns
  task automatic medir_un_periodo(output real p);
    @(posedge dut.clk10); t0 = $realtime;
    @(posedge dut.clk10); p  = $realtime - t0;
  endtask

`ifdef USE_SDF
  initial begin
    $display("[%0t] INFO: Cargando SDF ...", $time);
    $sdf_annotate("Uso_del_PLL_IP_core_impl.sdf", dut, , , "MAXIMUM");
  end
`endif

  initial begin
    $timeformat(-9, 3, " ns", 10);
    $display("[%0t] TB start", $time);

    // Libera reset tras unos ciclos
    repeat (4) @(posedge clk100);
    rst = 0;

    // Espera LOCK con timeout
    fork
      begin : timeout_lock
        #200_000; // 200 us
        if (!dut.locked) $fatal(1, "[%0t] FAIL: Timeout: el PLL no hizo lock.", $time);
      end
      begin : wait_lock
        @(posedge dut.locked);
        disable timeout_lock;
      end
    join_any
    disable fork;
    $display("[%0t] PLL locked", $time);

    // Estabiliza y mide 5 periodos
    repeat (10) @(posedge dut.clk10);
    samples_ok = 0;
    for (i = 0; i < 5; i++) begin
      medir_un_periodo(per_ns);
      $display("[%0t] clk10 period = %0.3f ns", $time, per_ns);
      if (per_ns > 98.0 && per_ns < 102.0) samples_ok++;
    end

    // Relación de ciclos: 10 flancos de clk100 por periodo de clk10
    for (i = 0; i < 4; i++) begin
      @(posedge dut.clk10);
      cycles100 = 0;
      do begin
        @(posedge clk100);
        cycles100++;
      end while (!dut.clk10);
      if (cycles100 != 10)
        $fatal(1, "[%0t] FAIL: ciclos clk100 por periodo clk10 = %0d (esperado 10)",
               $time, cycles100);
      else
        $display("[%0t] OK: ciclos clk100 por periodo clk10 = %0d", $time, cycles100);
    end

    if (samples_ok == 5) begin
      $display("\n[%0t] TEST PASS: clk10 ≈ 10 MHz y relación 100:10 verificada.\n", $time);
      $finish(0);
    end else begin
      $fatal(1, "\n[%0t] TEST FAIL: periodo fuera de rango (%0d/5 válidos).\n",
             $time, samples_ok);
    end
  end

`ifdef DUMP_VCD
  initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);
  end
`endif

endmodule
