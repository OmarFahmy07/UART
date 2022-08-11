module start_check(input wire data_in,
                   input clock,
                   input reset,
                   input wire enable,
                   output reg glitch);
    
    reg glitch_comb;
    
    always@(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            glitch <= 1'b0;
        end
        else
        begin
            glitch <= glitch_comb;
        end
    end
    
    always@(*)
    begin
        if (enable)
        begin
            glitch_comb = data_in;
        end
        else
        begin
            glitch_comb = glitch;
        end
    end
    
endmodule
