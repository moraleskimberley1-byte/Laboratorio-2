// debounce_onepulse.sv
// Sincroniza, des-rebota con ventana ~10 ms y entrega un pulso (1 clk) por flanco.
`timescale 1ns/1ps
module debounce_onepulse #(
  parameter int STABLE_MS = 10
)(
  input  logic clk,
  input  logic rst,
  input  logic ce_1khz,       // de clock_div (1 kHz)
  input  logic din_async,     // boton/switch asincronico
  output logic pulse          // pulso 1-ciclo en flanco de subida
);
  // Sincronizador a 2 FF
  logic s0, s1;
  always_ff @(posedge clk) begin
    s0 <= din_async;
    s1 <= s0;
  end

  // Debounce a 1 kHz: estado estable tras STABLE_MS muestras iguales
  localparam int CNT_MAX = STABLE_MS; // a 1 kHz: 10 ms -> 10 cuentas
  logic [$clog2(CNT_MAX+1)-1:0] cnt;
  logic stable, s1_prev_khz;

  always_ff @(posedge clk) begin
    if (rst) begin
      cnt <= '0; stable <= 1'b0; s1_prev_khz <= 1'b0;
    end else if (ce_1khz) begin
      if (s1 == s1_prev_khz) begin
        if (cnt < CNT_MAX) cnt <= cnt + 1;
      end else begin
        cnt <= '0;
      end
      if (cnt == CNT_MAX) stable <= s1;
      s1_prev_khz <= s1;
    end
  end

  // One-pulse al subir
  logic stable_d;
  always_ff @(posedge clk) begin
    if (rst) begin stable_d <= 1'b0; pulse <= 1'b0; end
    else begin stable_d <= stable; pulse <= (stable & ~stable_d); end
  end
endmodule
