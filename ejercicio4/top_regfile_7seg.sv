// ==========================================================
// top_regfile_7seg_nexys4.sv
// Demo: Banco de registros (8 x 8 bits) + display 7 segmentos
// Placa: Nexys-4 (XC7A100T-CSG324)
// Puertos: CLK100MHZ, BTNC, BTNU, SW[15:0], AN[7:0], CA..CG, DP
// ==========================================================
module top_regfile_7seg_nexys4 (
  input  wire        CLK100MHZ,
  input  wire        BTNC,        // reset (activo alto)
  input  wire        BTNU,        // botón WE (pulso)
  input  wire [15:0] SW,
  output wire [7:0]  AN,          // activo en BAJO (físico)
  output wire        CA, CB, CC, CD, CE, CF, CG, // activo en BAJO (físico)
  output wire        DP
);

  // --------- parámetros del banco ----------
  localparam int N = 3;   // 2^3 = 8 registros
  localparam int W = 8;   // 8 bits por registro

  // --------- reset sinc. y pulso de WE -----
  reg rst_sync = 1'b0;
  reg we_ff1   = 1'b0, we_ff2 = 1'b0;
  always @(posedge CLK100MHZ) begin
    rst_sync <= BTNC;
    we_ff1   <= BTNU;
    we_ff2   <= we_ff1;
  end
  wire we_pulse = we_ff1 & ~we_ff2;

  // --------- mapeo de switches -------------
  wire [W-1:0] data_in  = SW[7:0];     // dato a escribir
  wire [N-1:0] addr_rd  = SW[10:8];    // dirección de escritura
  wire [N-1:0] addr_rs1 = SW[13:11];   // dirección lectura 1
  wire [N-1:0] addr_rs2 = SW[15:13];   // dirección lectura 2

  // --------- banco de registros ------------
  wire [W-1:0] rs1, rs2;
  regfile #(.N(N), .W(W)) u_rf (
    .clk      (CLK100MHZ),
    .rst      (rst_sync),
    .we       (we_pulse),
    .addr_rd  (addr_rd),
    .addr_rs1 (addr_rs1),
    .addr_rs2 (addr_rs2),
    .data_in  (data_in),
    .rs1      (rs1),
    .rs2      (rs2)
  );

  // --------- empaquetado para 7-seg --------
  // d1..d0 (derecha) = rs1; d5..d4 (izquierda) = rs2
  // d7,d6,d3,d2 = 0 (verás "0" en esos dígitos)
  wire [31:0] digits_bus = {
    4'h0, 4'h0,          // d7..d6
    rs2[7:4], rs2[3:0],  // d5..d4
    4'h0, 4'h0,          // d3..d2
    rs1[7:4], rs1[3:0]   // d1..d0
  };

  // --------- driver 7 segmentos ------------
  wire [7:0] an_w;
  wire [6:0] seg_w;   // orden {CA,CB,CC,CD,CE,CF,CG} activo-BAJO
  wire       dp_w;

  sevenseg8 u_ss (
    .clk    (CLK100MHZ),
    .rst    (rst_sync),
    .digits (digits_bus),
    .an     (an_w),
    .seg    (seg_w),
    .dp     (dp_w)
  );

  // --------- conexiones directas -----------
  assign AN = an_w;                 // ya activo en bajo
  assign {CA,CB,CC,CD,CE,CF,CG} = seg_w; // MISMO ORDEN
  assign DP = dp_w;

endmodule
