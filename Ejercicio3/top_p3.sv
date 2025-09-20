// ========= top_p3.sv =========
module top_p3 (
    input  logic        CLK100MHZ,
    input  logic [15:0] SW,        // SW[15]=modo (1=LFSR, 0=Manual) + datos
    input  logic        SW_RST,    // reset ACTIVO ALTO
    input  logic        SW_WE,     // write enable manual
    input  logic        BTN_V10,   // mantener = corre LFSR
    output logic [7:0]  AN,
    output logic [6:0]  SEG,
    output logic        DP
);
    // -------- Modo --------
    logic mode_lfsr = SW[15];

    // -------- Debounce + flanco inmediato de BTN_V10 (≈10 ms) --------
    logic b0, b1, btn_db, btn_db_d, edge_up;
    logic [19:0] db_cnt;                 // 2^20 > 1_000_000
    always_ff @(posedge CLK100MHZ) begin
        b0 <= BTN_V10;
        b1 <= b0;
        if (SW_RST) begin
            btn_db <= 1'b0; db_cnt <= '0; btn_db_d <= 1'b0;
        end else begin
            if (b1 == btn_db) db_cnt <= '0;
            else if (db_cnt == 1_000_000-1) begin
                btn_db <= b1; db_cnt <= '0;
            end else db_cnt <= db_cnt + 1'b1;
            btn_db_d <= btn_db;
        end
    end
    assign edge_up = btn_db & ~btn_db_d; // 1 ciclo al tocar

    // -------- Enable periódico 200 Hz mientras se mantiene --------
    localparam int N200 = 500_000-1;     // 100MHz/200 -1
    localparam int W200 = 19;            // ceil(log2(500_000)) = 19
    logic [W200-1:0] c200;
    logic tick200;
    always_ff @(posedge CLK100MHZ) begin
        if (SW_RST) begin c200 <= '0; tick200 <= 1'b0;
        end else if (c200 == N200) begin c200 <= '0; tick200 <= 1'b1;
        end else begin c200 <= c200 + 1'b1; tick200 <= 1'b0; end
    end

    // -------- Enable final del LFSR --------
    logic lfsr_en = mode_lfsr ? (edge_up | (btn_db & tick200)) : SW_WE;

    // -------- LFSR --------
    logic [15:0] seed   = (SW == 16'h0000) ? 16'h1ACE : SW;
    logic [15:0] lfsr_q;
    lfsr16 u_lfsr (
        .clk  (CLK100MHZ),
        .rst  (SW_RST),
        .en   (mode_lfsr ? lfsr_en : 1'b0),
        .seed (seed),
        .q    (lfsr_q)
    );

    // -------- Datos / WE --------
    logic [15:0] d_in = mode_lfsr ? lfsr_q : SW;
    logic        we   = lfsr_en; // en manual, lfsr_en = SW_WE

    // -------- Registro y Display (tus módulos) --------
    logic [15:0] q_reg;
    reg_p #(.WIDTH(16)) u_reg (
        .clk (CLK100MHZ),
        .rst (SW_RST),      // si tu reg_p es activo-BAJO, usa .rst(~SW_RST)
        .we  (we),
        .d   (d_in),
        .q   (q_reg)
    );

    disp4_mux u_disp (
        .clk (CLK100MHZ),
        .rst (SW_RST),      // si tu display es activo-BAJO, usa .rst(~SW_RST)
        .data(q_reg),
        .an  (AN),
        .seg (SEG),
        .dp  (DP)
    );
endmodule
