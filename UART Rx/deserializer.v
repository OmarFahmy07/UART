module deserializer(input wire enable,
                    input wire clock,
                    input wire reset,
                    input wire data_in,
                    output reg [7:0] shift_reg);
    
    wire [7:0] temp_reg;
    reg [7:0] shift_reg_comb;
    
    always@(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            shift_reg <= 'd0;
        end
        else
        begin
            shift_reg <= shift_reg_comb;
        end
    end
    
    assign temp_reg = shift_reg >> 1;
    
    always@(*)
    begin
        if (enable)
        begin
            shift_reg_comb = { data_in, temp_reg[6:0] };
        end
        else
        begin
            shift_reg_comb = shift_reg;
        end
    end
    
endmodule
