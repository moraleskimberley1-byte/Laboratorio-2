// alu16.sv
// op: 2'b00=ADD, 01=SUB, 10=AND, 11=OR
`timescale 1ns/1ps
module alu16(
  input  logic [15:0] a,
  input  logic [15:0] b,
  input  logic [1:0]  op,
  output logic [15:0] y
);
  always_comb begin
    unique case (op)
      2'b00: y = a + b;
      2'b01: y = a - b;
      2'b10: y = a & b;
      default: y = a | b;
    endcase
  end
endmodule
