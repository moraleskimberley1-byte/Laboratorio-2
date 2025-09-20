`timescale 1ns/1ps
module control_fsm #(
  parameter ADDR_MAX = 32
)(
  input  wire        clk, rst,
  input  wire        mode_scan,      // SW[0]=1 -> modo 2 (recorrido)
  input  wire        tick_1s,        // para scan 1s
  input  wire        tick_2s,        // para mostrar A/B/RES 2s
  input  wire [3:0]  op_btn_pulse,   // {or,and,sub,add} un pulso
  // interfaz con datos
  input  wire [15:0] lfsr_ext,       // LFSR extendido a 16b
  input  wire [15:0] rdataA, rdataB, aluY,
  output reg         we,
  output reg  [4:0]  waddr, raddrA, raddrB,
  output reg  [15:0] wdata,
  output reg  [1:0]  op_sel,
  // salidas de UI
  output reg  [15:0] disp_data,
  output reg  [2:0]  led_which,      // A/B/RES: [0]=A [1]=B [2]=RES
  output reg  [3:0]  led_op          // one-hot op encendida
);
  typedef enum logic [3:0] {
    S_IDLE=0, S_GET_A, S_SHOW_A, S_GET_B, S_SHOW_B,
    S_WAIT_OP, S_EXEC, S_WRITE_RES, S_SHOW_RES, S_SCAN
  } state_t;

  state_t s, ns;
  reg [4:0] wp;          // write pointer circular
  reg [4:0] scan_idx;    // índice de recorrido
  reg [1:0] two_sec_cnt; // cuenta 1 tick de 2s

  // Latch botones a código de operación
  wire btn_add = op_btn_pulse[0];
  wire btn_sub = op_btn_pulse[1];
  wire btn_and = op_btn_pulse[2];
  wire btn_or  = op_btn_pulse[3];

  // Secuencial
  always @(posedge clk) begin
    if (rst) begin
      s <= S_IDLE; wp <= 0; scan_idx <= 0; two_sec_cnt<=0;
    end else begin
      s <= ns;
      if (s==S_SHOW_A || s==S_SHOW_B || s==S_SHOW_RES) begin
        if (tick_2s) two_sec_cnt <= two_sec_cnt + 1;
      end else two_sec_cnt <= 0;

      if (s==S_WRITE_RES) wp <= wp + 3;    // A,B,RES ocupan 3 posiciones
      if (s==S_SCAN && tick_1s) scan_idx <= scan_idx + 1;
      if (!mode_scan) scan_idx <= 0;       // reinicia salida de scan
    end
  end

  // Combinacional: por defecto
  always @* begin
    ns = s;
    we=0; waddr=0; wdata=0; raddrA=0; raddrB=0; op_sel=0;
    disp_data=16'h0000; led_which=3'b000; led_op=4'b0000;

    if (mode_scan) begin
      // Prioridad a modo de recorrido
      ns = S_SCAN;
      disp_data = (scan_idx < ADDR_MAX) ? rdataA : 16'h0000; // usaremos raddrA=scan_idx
      raddrA = scan_idx;
      if (tick_1s) ns = S_SCAN; // loop
    end else begin
      case (s)
        S_IDLE:      ns = S_GET_A;

        S_GET_A: begin
          we=1; waddr=wp; wdata=lfsr_ext;
          ns=S_SHOW_A; disp_data=lfsr_ext; led_which=3'b001;
        end

        S_SHOW_A: begin
          disp_data = lfsr_ext; led_which=3'b001;
          if (two_sec_cnt==1) ns=S_GET_B; // tras ~2s
        end

        S_GET_B: begin
          we=1; waddr=wp+1; wdata=lfsr_ext;
          ns=S_SHOW_B; disp_data=lfsr_ext; led_which=3'b010;
        end

        S_SHOW_B: begin
          disp_data = lfsr_ext; led_which=3'b010;
          if (two_sec_cnt==1) ns=S_WAIT_OP;
        end

        S_WAIT_OP: begin
          // indica operación con leds cuando se pulsa
          led_op = {btn_or, btn_and, btn_sub, btn_add};
          if (btn_add) begin op_sel=2'b00; ns=S_EXEC; end
          else if (btn_sub) begin op_sel=2'b01; ns=S_EXEC; end
          else if (btn_and) begin op_sel=2'b10; ns=S_EXEC; end
          else if (btn_or)  begin op_sel=2'b11; ns=S_EXEC; end
        end

        S_EXEC: begin
          raddrA=wp; raddrB=wp+1;
          ns=S_WRITE_RES;
        end

        S_WRITE_RES: begin
          we=1; waddr=wp+2; wdata=aluY;
          ns=S_SHOW_RES;
        end

        S_SHOW_RES: begin
          raddrA=wp; raddrB=wp+1;
          disp_data = aluY; led_which=3'b100;
          if (two_sec_cnt==1) ns=S_IDLE;
        end
      endcase
    end
  end
endmodule
