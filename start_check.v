module start_check(input wire data_in,
                   input wire enable,
                   output reg glitch);
    
    always@(*)
    begin
        if (enable)
        begin
            glitch = data_in ? 1'b1 : 1'b0;
        end
        else
        begin
            glitch = 1'b0;
        end
    end
    
endmodule
