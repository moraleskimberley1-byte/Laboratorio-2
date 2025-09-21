module tb_regfile;
    parameter N = 3, W = 8;
    logic clk, rst, we;
    logic [N-1:0] addr_rd, addr_rs1, addr_rs2;
    logic [W-1:0] data_in;
    logic [W-1:0] rs1, rs2;

    regfile #(.N(N), .W(W)) uut (
        .clk(clk), .rst(rst), .we(we),
        .addr_rd(addr_rd), .addr_rs1(addr_rs1), .addr_rs2(addr_rs2),
        .data_in(data_in), .rs1(rs1), .rs2(rs2)
    );

    always #5 clk = ~clk;

    initial begin
        clk=0; rst=1; we=0;
        #10 rst=0;

        // Escribir en todos los registros
        for (int i=1; i<2**N; i++) begin
            @(posedge clk);
            we=1;
            addr_rd=i;
            data_in=$urandom;
        end
        we=0;

        // Leer con direcciones aleatorias
        repeat (10) begin
            @(posedge clk);
            addr_rs1=$urandom_range(0,2**N-1);
            addr_rs2=$urandom_range(0,2**N-1);
        end
        #50 $finish;
    end
endmodule
