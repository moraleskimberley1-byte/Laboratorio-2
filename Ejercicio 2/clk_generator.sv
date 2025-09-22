module clk_generator (
    input  logic clk_100mhz,
    input  logic rst_n,
    output logic clk_10mhz
);

    logic [2:0] counter;
    logic clk_reg;
    
    always_ff @(posedge clk_100mhz or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 3'b000;
            clk_reg <= 1'b0;
        end else begin
            if (counter == 3'd4) begin  // Divide by 10: 100MHz/10 = 10MHz
                counter <= 3'b000;
                clk_reg <= ~clk_reg;
            end else begin
                counter <= counter + 1'b1;
            end
        end
    end
    
    assign clk_10mhz = clk_reg;

endmodule