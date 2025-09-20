// clock_div.sv
// Genera clock-enables limpios desde 100 MHz: 1 kHz, 1 Hz y 2 Hz.
`timescale 1ns/1ps
module clock_div #(
  parameter int CLK_HZ = 100_000_000
)(
  input  logic clk,
  input  logic rst,           // sincrono, activo alto
  output logic ce_1khz,       // ~1 ms
  output logic ce_1hz,        // ~1 s
  output logic ce_2hz         // ~0.5 s
);
  // 1 kHz
  localparam int DIV_1KHZ = CLK_HZ/1_000;
  logic [$clog2(DIV_1KHZ)-1:0] c1k;
  always_ff @(posedge clk) begin
    if (rst) begin c1k <= 0; ce_1khz <= 1'b0; end
    else begin
      if (c1k == DIV_1KHZ-1) begin c1k <= 0; ce_1khz <= 1'b1; end
      else begin c1k <= c1k + 1; ce_1khz <= 1'b0; end
    end
  end

  // 1 Hz
  localparam int DIV_1HZ = CLK_HZ/1;
  logic [$clog2(DIV_1HZ)-1:0] c1;
  always_ff @(posedge clk) begin
    if (rst) begin c1 <= 0; ce_1hz <= 1'b0; end
    else begin
      if (c1 == DIV_1HZ-1) begin c1 <= 0; ce_1hz <= 1'b1; end
      else begin c1 <= c1 + 1; ce_1hz <= 1'b0; end
    end
  end

  // 2 Hz
  localparam int DIV_2HZ = CLK_HZ/2;
  logic [$clog2(DIV_2HZ)-1:0] c2;
  always_ff @(posedge clk) begin
    if (rst) begin c2 <= 0; ce_2hz <= 1'b0; end
    else begin
      if (c2 == DIV_2HZ-1) begin c2 <= 0; ce_2hz <= 1'b1; end
      else begin c2 <= c2 + 1; ce_2hz <= 1'b0; end
    end
  end
endmodule
