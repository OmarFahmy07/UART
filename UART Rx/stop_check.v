module stop_check(input wire data_in,
                  input wire enable,
                  input wire load,
                  input wire reset,
                  output reg stop_error);
    
    reg temp_reg;
    
    always@(posedge load or negedge reset)
    begin
        if (!reset)
        begin
            temp_reg <= 1'b0;
        end
        else
        begin
            temp_reg <= data_in;
        end
    end
    
    always@(*)
    begin
        if (enable)
        begin
            stop_error = temp_reg ? 1'b0 : 1'b1;
        end
        else
        begin
            stop_error = 1'b0;
        end
    end
endmodule
