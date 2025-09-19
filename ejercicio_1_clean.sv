module Uso_del_PLL_IP_core(
    input  logic clk100,     // pin externo 100 MHz
    input  logic rst,        // reset activo alto (botón)
    output logic led
);
    // ===== Buffer del reloj de entrada (no usar puerto crudo como clk) =====
    wire clk100_ibuf, clk100_bufg;
    IBUF ibuf_inst (.I(clk100), .O(clk100_ibuf));
    BUFG bufg_inst (.I(clk100_ibuf), .O(clk100_bufg));

    // ===== Clocking Wizard: 100 MHz -> 10 MHz =====
    (* MARK_DEBUG="TRUE" *) logic clk10;     // 10 MHz generado
    (* MARK_DEBUG="TRUE" *) logic locked;    // '1' cuando PLL estable

    clk_wiz_1 pll_inst (
        .clk_in1 (clk100_bufg),
        .reset   (rst),        // tu IP usa reset activo ALTO
        .clk_out1(clk10),
        .locked  (locked)
        // si habilitas clk_out2=100 MHz, puedes usarlo en lugar de clk100_bufg
    );

    // ===== Reset sincronizado al dominio de 10 MHz =====
    // Mantiene en reset el dominio lento hasta que locked=1
    (* ASYNC_REG="TRUE" *) logic [1:0] rst_sync10;
    always_ff @(posedge clk10 or posedge rst) begin
        if (rst)          rst_sync10 <= 2'b11;
        else              rst_sync10 <= {rst_sync10[0], ~locked};
    end
    (* MARK_DEBUG="TRUE" *) wire rst_clk10 = rst_sync10[1];

    // ===== Dominio 100 MHz =====
    // Toggle visible (~50 MHz) para comprobar el reloj rápido en el ILA
    (* MARK_DEBUG="TRUE" *) logic t100;
    always_ff @(posedge clk100_bufg or posedge rst) begin
        if (rst) t100 <= 1'b0;
        else     t100 <= ~t100;
    end

    // Sincroniza clk10 al dominio de 100 MHz para detectar flancos
    (* ASYNC_REG="TRUE" *) logic clk10_q1, clk10_q2;
    always_ff @(posedge clk100_bufg or posedge rst) begin
        if (rst) begin
            clk10_q1 <= 1'b0;
            clk10_q2 <= 1'b0;
        end else begin
            clk10_q1 <= clk10;
            clk10_q2 <= clk10_q1;
        end
    end
    wire clk10_rise_100 = clk10_q1 & ~clk10_q2;

    // Medidor: cuántos ciclos de 100 MHz caben en un ciclo de 10 MHz (~10)
    logic [7:0] acc;
    (* MARK_DEBUG="TRUE" *) logic [7:0] cycles_100_between_clk10;
    always_ff @(posedge clk100_bufg or posedge rst) begin
        if (rst) begin
            acc <= '0;
            cycles_100_between_clk10 <= '0;
        end else begin
            acc <= acc + 1'b1;
            if (clk10_rise_100) begin
                cycles_100_between_clk10 <= acc;
                acc <= '0;
            end
        end
    end

    // ===== Dominio 10 MHz =====
    // Toggle lento (~5 MHz) para "ver" el reloj de 10 MHz en ILA
    (* MARK_DEBUG="TRUE" *) logic t10;
    always_ff @(posedge clk10 or posedge rst_clk10) begin
        if (rst_clk10) t10 <= 1'b0;
        else           t10 <= ~t10;
    end

    // Contador pequeño en 10 MHz (útil para ver bits como ondas cuadradas)
    (* MARK_DEBUG="TRUE" *) logic [3:0] cnt10;
    always_ff @(posedge clk10 or posedge rst_clk10) begin
        if (rst_clk10) cnt10 <= '0;
        else           cnt10 <= cnt10 + 1'b1;
    end

    // Contador grande para el LED
    logic [23:0] counter;
    always_ff @(posedge clk10 or posedge rst_clk10) begin
        if (rst_clk10) counter <= '0;
        else           counter <= counter + 1'b1;
    end

    assign led = counter[23];

endmodule
