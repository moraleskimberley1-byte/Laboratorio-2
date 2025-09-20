// lfsr7.sv
// LFSR de 7 bits (x^7 + x^6 + 1), salida en [6:0]. Avanza con 'step'.
`timescale 1ns/1ps
module lfsr7(
  input  logic clk,
  input  logic rst,
  input  logic step,        // un pulso avanza una muestra
  output logic [6:0] rnd    // 7-bit pseudo-aleatorio
);
  logic [6:0] r;
  wire  fb = r[6] ^ r[5];   // taps 7 y 6

  always_ff @(posedge clk) begin
    if (rst)       r <= 7'h5A;          // semilla no cero
    else if (step) r <= {r[5:0], fb};
  end

  assign rnd = r;
endmodule
