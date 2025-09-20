// mini_calc_top.sv
// TOP del sistema del punto 5: mini unidad de calculo.
// - Unico dominio de reloj (CLK100MHZ)
// - clock_enables: 1kHz (scan), 1Hz/2Hz (tiempos visibles)
// - LFSR 7-bit -> operandos 16-bit (zero-extend)
// - Regfile 32x16 (reg[0]=0 de solo lectura)
// - ALU 16-bit: ADD/SUB/AND/OR
// - FSM con dos modos: calculo (SW0=0) y recorrido (SW0=1)
// - En calculo: A y B se guardan inmediatamente al capturarse.
// - En recorrido: se muestran duplas A,B ya capturadas (pair_cnt);
//   y R solo si esa dupla ya tiene resultado (br_idx < triplet_cnt).

`timescale 1ns/1ps
module mini_calc_top #(
  parameter int CLK_HZ = 100_000_000
)(
  input  logic        CLK100MHZ,
  input  logic        RESET,          // BTNC (activo alto)
  input  logic [15:0] SW,             // SW[0]=modo (0=calculo, 1=recorrido)
  input  logic [3:0]  BTN,            // BTN[0]=ADD, [1]=SUB, [2]=AND, [3]=OR
  output logic [15:0] LED,            // Indicadores
  output logic [6:0]  SEG,
  output logic        DP,
  output logic [7:0]  AN
);

  // -----------------------------
  //  Reloj y enables
  // -----------------------------
  logic ce_1khz, ce_1hz, ce_2hz;
  clock_div #(.CLK_HZ(CLK_HZ)) udiv (
    .clk(CLK100MHZ), .rst(RESET),
    .ce_1khz(ce_1khz), .ce_1hz(ce_1hz), .ce_2hz(ce_2hz)
  );

  // -----------------------------
  //  Anti-rebote + one-pulse
  // -----------------------------
  logic p_add, p_sub, p_and, p_or;
  debounce_onepulse udb_add(.clk(CLK100MHZ), .rst(RESET), .ce_1khz(ce_1khz), .din_async(BTN[0]), .pulse(p_add));
  debounce_onepulse udb_sub(.clk(CLK100MHZ), .rst(RESET), .ce_1khz(ce_1khz), .din_async(BTN[1]), .pulse(p_sub));
  debounce_onepulse udb_and(.clk(CLK100MHZ), .rst(RESET), .ce_1khz(ce_1khz), .din_async(BTN[2]), .pulse(p_and));
  debounce_onepulse udb_or (.clk(CLK100MHZ), .rst(RESET), .ce_1khz(ce_1khz), .din_async(BTN[3]), .pulse(p_or));

  // -----------------------------
  //  LFSR 7-bit -> 16-bit
  // -----------------------------
  logic [6:0]  rnd7;
  logic        step_lfsr;
  lfsr7 ulfsr(.clk(CLK100MHZ), .rst(RESET), .step(step_lfsr), .rnd(rnd7));
  wire  [15:0] rnd16 = {9'b0, rnd7};

  // -----------------------------
  //  Banco de registros 32x16
  // -----------------------------
  logic        rf_we;
  logic [4:0]  rf_waddr, rf_raddr_a, rf_raddr_b;
  logic [15:0] rf_wdata, rf_rs1, rf_rs2;
  regfile32x16 urf(
    .clk(CLK100MHZ), .rst(RESET),
    .we(rf_we), .addr_rd(rf_waddr), .data_in(rf_wdata),
    .addr_rs1(rf_raddr_a), .addr_rs2(rf_raddr_b),
    .rs1(rf_rs1), .rs2(rf_rs2)
  );

  // -----------------------------
  //  ALU 16-bit
  // -----------------------------
  logic [1:0]  op_sel;
  logic [15:0] alu_y;
  alu16 ualu(.a(rf_rs1), .b(rf_rs2), .op(op_sel), .y(alu_y));

  // -----------------------------
  //  Display 7-seg
  // -----------------------------
  logic [15:0] disp_val;
  display_hex4 u7seg(
    .clk(CLK100MHZ), .rst(RESET), .ce_scan(ce_1khz),
    .value(disp_val), .SEG(SEG), .DP(DP), .AN(AN)
  );

  // -----------------------------
  //  FSM de control
  // -----------------------------
  typedef enum logic [3:0] {
    S_IDLE,
    S_GRAB_A, S_SHOW_A,     // toma LFSR->A, muestra ~2 s (ce_2hz)
    S_GRAB_B, S_SHOW_B,     // toma LFSR->B, muestra ~2 s (ce_2hz)
    S_WAIT_OP,              // espera boton para op
    S_EXEC_ALU,             // ejecuta ALU(A,B)
    S_STORE_RES,            // guarda R y muestra 1 s (ce_1hz)
    S_NEXT_TRIPLET,         // avanza indice de productor
    S_BROWSE                // modo recorrido: A->B->(R si existe) 1 s cada uno
  } state_t;

  state_t st, st_n;

  // -----------------------------
  //  Indices y contadores
  // -----------------------------
  // productor (calculo) y navegador (recorrido)
  logic [3:0] prod_idx,  prod_idx_n;     // 0..9 donde se escriben A/B/R
  logic [3:0] br_idx,    br_idx_n;       // 0..9 que se recorre al mostrar

  // cuantas duplas A,B hay capturadas (aunque no tengan R)
  logic [3:0] pair_cnt,  pair_cnt_n;     // 0..10

  // cuantas tripletas A,B,R completas hay
  logic [3:0] triplet_cnt, triplet_cnt_n; // 0..10

  // fuente de direccion segun modo
  logic [3:0] idx_src;
  always_comb begin
    if (st == S_BROWSE) idx_src = br_idx;
    else                idx_src = prod_idx;
  end

  // offs = idx_src * 3 (0..27)
  logic [6:0] offs;
  always_comb begin
    offs = {3'b000, idx_src} * 3;
  end

  // Direcciones A,B,R dentro del regfile
  wire [4:0] addr_A = 5'd1 + offs[4:0];
  wire [4:0] addr_B = 5'd2 + offs[4:0];
  wire [4:0] addr_R = 5'd3 + offs[4:0];

  // Temporizadores y operacion latcheada
  logic [1:0] sec_cnt, sec_cnt_n;      // fase A/B/R para SHOW_* y BROWSE
  logic [1:0] op_latched, op_latched_n;

  // -----------------------------
  //  LEDs (indicadores)
  // -----------------------------
  assign LED[0]   = SW[0];              // modo: 0=calc, 1=browse
  assign LED[1]   = (st == S_SHOW_A);   // mostrando A
  assign LED[2]   = (st == S_SHOW_B);   // mostrando B
  assign LED[3]   = (st == S_WAIT_OP);  // esperando op
  assign LED[7:4] = (st==S_EXEC_ALU || st==S_STORE_RES) ?
                    (op_latched==2'b00 ? 4'b0001 :
                     op_latched==2'b01 ? 4'b0010 :
                     op_latched==2'b10 ? 4'b0100 : 4'b1000) : 4'b0000;
  assign LED[15:8]= 8'h00;

  // -----------------------------
  //  Proxima logica de estado
  // -----------------------------
  always_comb begin
    // Defaults
    rf_we        = 1'b0;
    rf_waddr     = 5'd0;
    rf_wdata     = 16'h0000;
    rf_raddr_a   = addr_A;
    rf_raddr_b   = addr_B;
    step_lfsr    = 1'b0;
    op_sel       = op_latched;
    disp_val     = 16'h0000;

    st_n         = st;
    sec_cnt_n    = sec_cnt;
    op_latched_n = op_latched;

    prod_idx_n   = prod_idx;
    br_idx_n     = br_idx;
    pair_cnt_n   = pair_cnt;
    triplet_cnt_n= triplet_cnt;

    unique case (st)
      // -------------------------
      S_IDLE: begin
        disp_val = 16'h0000;
        if (SW[0]) begin
          // Entrando a recorrido: arrancar limpio en A del indice 0
          sec_cnt_n = '0;
          br_idx_n  = 4'd0;
          st_n      = S_BROWSE;
        end else begin
          st_n = S_GRAB_A;
        end
      end

      // -------------------------
      S_GRAB_A: begin
        step_lfsr = 1'b1;
        rf_we     = 1'b1;
        rf_waddr  = addr_A;      // A en la dupla prod_idx
        rf_wdata  = rnd16;
        sec_cnt_n = '0;
        st_n      = S_SHOW_A;
      end

      S_SHOW_A: begin
        rf_raddr_a = addr_A;
        disp_val   = rf_rs1;
        if (ce_2hz) sec_cnt_n = sec_cnt + 1;
        if (sec_cnt == 2'd3) st_n = S_GRAB_B;
        if (SW[0]) begin
          sec_cnt_n = '0; br_idx_n = 4'd0; st_n = S_BROWSE;
        end
      end

      // -------------------------
      S_GRAB_B: begin
        step_lfsr = 1'b1;
        rf_we     = 1'b1;
        rf_waddr  = addr_B;      // B en la dupla prod_idx
        rf_wdata  = rnd16;
        sec_cnt_n = '0;
        st_n      = S_SHOW_B;

        // si es una nueva dupla, aumenta pair_cnt (hasta 10)
        if (pair_cnt < 4'd10) pair_cnt_n = pair_cnt + 4'd1;
      end

      S_SHOW_B: begin
        rf_raddr_b = addr_B;
        disp_val   = rf_rs2;
        if (ce_2hz) sec_cnt_n = sec_cnt + 1;
        if (sec_cnt == 2'd3) st_n = S_WAIT_OP;
        if (SW[0]) begin
          sec_cnt_n = '0; br_idx_n = 4'd0; st_n = S_BROWSE;
        end
      end

      // -------------------------
      S_WAIT_OP: begin
        disp_val = 16'hCA1C; // marcador simple mientras espera
        if (p_add)      begin op_latched_n = 2'b00; st_n = S_EXEC_ALU; end
        else if (p_sub) begin op_latched_n = 2'b01; st_n = S_EXEC_ALU; end
        else if (p_and) begin op_latched_n = 2'b10; st_n = S_EXEC_ALU; end
        else if (p_or ) begin op_latched_n = 2'b11; st_n = S_EXEC_ALU; end

        if (SW[0]) begin
          sec_cnt_n = '0; br_idx_n = 4'd0; st_n = S_BROWSE;
        end
      end

      // -------------------------
      S_EXEC_ALU: begin
        // ALU ya tiene rs1, rs2 y op_sel
        disp_val = alu_y;
        st_n     = S_STORE_RES;
      end

      S_STORE_RES: begin
        // Guarda R y muestra ~1 s
        rf_we    = 1'b1;
        rf_waddr = addr_R;       // R en la misma dupla prod_idx
        rf_wdata = alu_y;
        disp_val = alu_y;
        if (ce_1hz) begin
          if (triplet_cnt < 4'd10) triplet_cnt_n = triplet_cnt + 4'd1;
          st_n = S_NEXT_TRIPLET;
        end
      end

      S_NEXT_TRIPLET: begin
        // Avanza indice del productor 0..9 para el siguiente trio
        prod_idx_n = (prod_idx == 4'd9) ? 4'd0 : (prod_idx + 4'd1);
        st_n       = S_GRAB_A;
      end

      // -------------------------
      S_BROWSE: begin
        // si no hay duplas, mostrar 0000
        if (pair_cnt == 4'd0) begin
          disp_val = 16'h0000;
        end else begin
          // Mostrar A -> B -> (R si existe) para la dupla br_idx
          unique case (sec_cnt)
            2'd0: begin // A
              rf_raddr_a = addr_A; 
              disp_val   = rf_rs1;
            end
            2'd1: begin // B
              rf_raddr_b = addr_B; 
              disp_val   = rf_rs2;
            end
            2'd2: begin // R (solo si esa dupla ya tiene resultado)
              if (br_idx < triplet_cnt) begin
                rf_raddr_a = addr_R; 
                disp_val   = rf_rs1;
              end else begin
                disp_val   = 16'h0000; // aun no hay R para esta dupla
              end
            end
            default: disp_val = 16'h0000;
          endcase

          if (ce_1hz) begin
            if (sec_cnt == 2'd2) begin
              sec_cnt_n = 2'd0;
              // siguiente dupla a recorrer: 0 .. (pair_cnt - 1)
              if (br_idx + 4'd1 >= pair_cnt) br_idx_n = 4'd0;
              else                            br_idx_n = br_idx + 4'd1;
            end else begin
              sec_cnt_n = sec_cnt + 1;
            end
          end
        end

        // Salir de recorrido -> vuelve a calcular desde el siguiente trio
        if (!SW[0]) begin
          sec_cnt_n = '0;
          st_n      = S_GRAB_A;
        end
      end

      // -------------------------
      default: st_n = S_IDLE;
    endcase
  end

  // -----------------------------
  //  Registros de estado
  // -----------------------------
  always_ff @(posedge CLK100MHZ) begin
    if (RESET) begin
      st            <= S_IDLE;
      sec_cnt       <= '0;
      op_latched    <= 2'b00;

      prod_idx      <= '0;
      br_idx        <= '0;
      pair_cnt      <= 4'd0;
      triplet_cnt   <= 4'd0;

    end else begin
      st            <= st_n;
      sec_cnt       <= sec_cnt_n;
      op_latched    <= op_latched_n;

      prod_idx      <= prod_idx_n;
      br_idx        <= br_idx_n;
      pair_cnt      <= pair_cnt_n;
      triplet_cnt   <= triplet_cnt_n;
    end
  end

endmodule
