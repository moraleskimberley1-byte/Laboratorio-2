// display_hex4.sv
// Muestra un valor de 16 bits en 4 digitos hex del 7-seg (anodos activos en bajo).
// SEG[6:0] activos en bajo. DP apagado por defecto.
`timescale 1ns/1ps
module display_hex4(
  input  logic        clk,
  input  logic        rst,
  input  logic        ce_scan,      // ~1 kHz recomendado
  input  logic [15:0] value,        // 4 nibbles hex
  output logic [6:0]  SEG,          // a,b,c,d,e,f,g (activos en bajo)
  output logic        DP,           // punto decimal (activo en bajo)
  output logic [7:0]  AN            // anodos (activos en bajo). Usamos AN[3:0]
);
  logic [1:0] dig_sel;
  logic [3:0] nib;

  // Escaneo
  always_ff @(posedge clk) begin
    if (rst) dig_sel <= 2'd0;
    else if (ce_scan) dig_sel <= dig_sel + 2'd1;
  end

  always_comb begin
    unique case (dig_sel)
      2'd0: nib = value[3:0];
      2'd1: nib = value[7:4];
      2'd2: nib = value[11:8];
      default: nib = value[15:12];
    endcase
  end

  // Decoder hex -> segmentos (activos en bajo)
  function automatic [6:0] hex2seg(input logic [3:0] h);
    unique case (h)
      4'h0: hex2seg = 7'b1000000;
      4'h1: hex2seg = 7'b1111001;
      4'h2: hex2seg = 7'b0100100;
      4'h3: hex2seg = 7'b0110000;
      4'h4: hex2seg = 7'b0011001;
      4'h5: hex2seg = 7'b0010010;
      4'h6: hex2seg = 7'b0000010;
      4'h7: hex2seg = 7'b1111000;
      4'h8: hex2seg = 7'b0000000;
      4'h9: hex2seg = 7'b0010000;
      4'hA: hex2seg = 7'b0001000;
      4'hB: hex2seg = 7'b0000011;
      4'hC: hex2seg = 7'b1000110;
      4'hD: hex2seg = 7'b0100001;
      4'hE: hex2seg = 7'b0000110;
      default: hex2seg = 7'b0001110; // F
    endcase
  endfunction

  always_comb begin
    AN = 8'hFF; DP = 1'b1; SEG = 7'h7F;
    SEG = hex2seg(nib);
    unique case (dig_sel)
      2'd0: AN = 8'b1111_1110;
      2'd1: AN = 8'b1111_1101;
      2'd2: AN = 8'b1111_1011;
      2'd3: AN = 8'b1111_0111;
      default: AN = 8'b1111_1111;
    endcase
  end
endmodule
