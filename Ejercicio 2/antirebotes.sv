module antirebotes #(
    parameter COUNTER_BITS = 16
)(
    input  logic clk,
    input  logic rst_n,
    input  logic button_in,
    output logic button_clean
);

    logic [COUNTER_BITS-1:0] counter;
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= '0;
            button_clean <= 1'b0;
        end else begin
            if (button_in == button_clean) begin
                counter <= '0;
            end else begin
                if (counter == {COUNTER_BITS{1'b1}}) begin
                    button_clean <= button_in;
                    counter <= '0;
                end else begin
                    counter <= counter + 1;
                end
            end
        end
    end

endmodule