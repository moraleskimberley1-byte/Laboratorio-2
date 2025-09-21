// sevenseg8.sv CORREGIDO
// Driver multiplexado para 8 dígitos (común ánodo) de Nexys-4/Nexys-4 DDR.
// Segmentos CA..CG y AN[7:0] ACTIVO EN BAJO. DP apagado por defecto.
module sevenseg8 (
  input  wire        clk,      // 100 MHz
  input  wire        rst,      // reset síncrono
  input  wire [31:0] digits,   // 8 nibbles: d7..d0 (d0 = derecha)
  output reg  [7:0]  an,       // ánodos activos en bajo (AN[0] = derecha)
  output reg  [6:0]  seg,      // {CA,CB,CC,CD,CE,CF,CG} activos en bajo
  output reg         dp        // punto decimal (activo en bajo)
);
  // Divisor para multiplexar (~700-800 Hz de refresco completo)
  reg [16:0] cnt;
  always @(posedge clk) begin
    if (rst) cnt <= 0;
    else     cnt <= cnt + 1;
  end
  wire [2:0] sel = cnt[16:14]; // recorre 0..7
  
  // Selección del nibble según dígito activo
  reg [3:0] nibble;
  always @* begin
    case (sel)
      3'd0: nibble = digits[ 3: 0];   // d0 (derecha)
      3'd1: nibble = digits[ 7: 4];   // d1
      3'd2: nibble = digits[11: 8];   // d2
      3'd3: nibble = digits[15:12];   // d3
      3'd4: nibble = digits[19:16];   // d4
      3'd5: nibble = digits[23:20];   // d5
      3'd6: nibble = digits[27:24];   // d6
      3'd7: nibble = digits[31:28];   // d7 (izquierda)
    endcase
  end
  
  // HEX → 7 segmentos activo-BAJO (0=encendido, 1=apagado)
  // Orden: {CA,CB,CC,CD,CE,CF,CG} = {A,B,C,D,E,F,G}
  //
  //  AAA     CA
  // F   B   CF CB
  // F   B   CF CB  
  //  GGG     CG
  // E   C   CE CC
  // E   C   CE CC
  //  DDD     CD
  //
  function automatic [6:0] hex7 (input [3:0] v);
    case (v)
      4'h0: hex7 = 7'b0000001; // {A,B,C,D,E,F,G} = {0,0,0,0,0,0,1} = encender ABCDEF
      4'h1: hex7 = 7'b1001111; // {A,B,C,D,E,F,G} = {1,0,0,1,1,1,1} = encender BC
      4'h2: hex7 = 7'b0010010; // {A,B,C,D,E,F,G} = {0,0,1,0,0,1,0} = encender ABDEG
      4'h3: hex7 = 7'b0000110; // {A,B,C,D,E,F,G} = {0,0,0,0,1,1,0} = encender ABCDG
      4'h4: hex7 = 7'b1001100; // {A,B,C,D,E,F,G} = {1,0,0,1,1,0,0} = encender BCFG
      4'h5: hex7 = 7'b0100100; // {A,B,C,D,E,F,G} = {0,1,0,0,1,0,0} = encender ACDFG
      4'h6: hex7 = 7'b0100000; // {A,B,C,D,E,F,G} = {0,1,0,0,0,0,0} = encender ACDEFG
      4'h7: hex7 = 7'b0001111; // {A,B,C,D,E,F,G} = {0,0,0,1,1,1,1} = encender ABC
      4'h8: hex7 = 7'b0000000; // {A,B,C,D,E,F,G} = {0,0,0,0,0,0,0} = encender ABCDEFG
      4'h9: hex7 = 7'b0000100; // {A,B,C,D,E,F,G} = {0,0,0,0,1,0,0} = encender ABCDFG
      4'hA: hex7 = 7'b0001000; // A = encender ABCEFG
      4'hB: hex7 = 7'b1100000; // b = encender CDEFG
      4'hC: hex7 = 7'b0110001; // C = encender ADEF
      4'hD: hex7 = 7'b1000010; // d = encender BCDEG
      4'hE: hex7 = 7'b0110000; // E = encender ADEFG
      4'hF: hex7 = 7'b0111000; // F = encender AEFG
    endcase
  endfunction
  
  // Multiplexado: encender un solo ánodo y sus segmentos
  always @* begin
    an  = 8'b11111111;   // todos apagados (común ánodo)
    seg = 7'b1111111;    // segmentos apagados
    dp  = 1'b1;          // dp apagado
    an[sel] = 1'b0;      // habilita un dígito (activo en bajo)
    seg     = hex7(nibble);
  end
endmodule