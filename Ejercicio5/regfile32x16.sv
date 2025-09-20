// regfile32x16.sv
// Banco de 32 registros de 16 bits: 1 puerto de escritura, 2 de lectura.
// Reg[0] es solo-lectura y siempre 0x0000.
`timescale 1ns/1ps
module regfile32x16(
  input  logic        clk,
  input  logic        rst,
  // Write
  input  logic        we,
  input  logic [4:0]  addr_rd,
  input  logic [15:0] data_in,
  // Read ports
  input  logic [4:0]  addr_rs1,
  input  logic [4:0]  addr_rs2,
  output logic [15:0] rs1,
  output logic [15:0] rs2
);
  logic [15:0] mem [31:0];

  // Escritura
  always_ff @(posedge clk) begin
    if (rst) begin
      integer i; for (i=0; i<32; i++) mem[i] <= '0;
    end else if (we && (addr_rd != 5'd0)) begin
      mem[addr_rd] <= data_in;
    end
  end

  // Lecturas combinacionales
  assign rs1 = (addr_rs1 == 5'd0) ? 16'h0000 : mem[addr_rs1];
  assign rs2 = (addr_rs2 == 5'd0) ? 16'h0000 : mem[addr_rs2];
endmodule
