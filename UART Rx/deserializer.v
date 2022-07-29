module deserializer(input wire enable,
                    input wire reset,
                    input wire data_in,
                    output reg [7:0] shift_reg);
    
    wire [7:0] shift_reg_comb, temp_reg;
    
    always@(posedge enable or negedge reset)
    begin
        if (!reset)
        begin
            // Idle signal is high
            shift_reg <= 'd1;
        end
        else
        begin
            shift_reg <= shift_reg_comb;
        end
    end
    
    assign temp_reg       = shift_reg >> 1;
    assign shift_reg_comb = { data_in, temp_reg[6:0] };
    
endmodule
