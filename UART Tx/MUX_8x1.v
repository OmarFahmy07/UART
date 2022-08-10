module MUX_8x1(input wire clk,
               input wire rst,
               input wire [2:0] sel,
               input wire [7:0] data,
               output reg out);
    
    wire out_comb;
    
    always@(posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            // IDLE bit is high
            out <= 1'b1;
        end
        else
        begin
            out <= out_comb;
        end
    end
    
    assign out_comb = data[sel];
    
endmodule
