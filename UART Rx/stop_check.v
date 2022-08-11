module stop_check(input wire data_in,
                  input wire enable,
                  input wire clock,
                  input wire reset,
                  output reg stop_error);
    
    reg stop_error_comb;
    
    always@(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            stop_error <= 1'b0;
        end
        else
        begin
            stop_error <= stop_error_comb;
        end
    end
    
    always@(*)
    begin
        if (enable)
        begin
            stop_error_comb = !data_in;
        end
        else
        begin
            stop_error_comb = stop_error;
        end
    end
endmodule
