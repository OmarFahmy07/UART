module Parity_Calc(input wire rst,
                   input wire clk,
                   input wire [7:0] data_in,
                   input wire load,
                   input wire type,
                   output reg parity_result);
    
    localparam  EVEN_PARITY = 1'b0,
    ODD_PARITY = 1'b1;
    
    reg parity_result_comb;
    
    always @(posedge clk or negedge rst)
    begin
        if (!rst)
        begin
            parity_result <= 1'b0;
        end
        else
        begin
            parity_result <= parity_result_comb;
        end
    end
    
    always@(*)
    begin
        // The load signal lets the parity calculator block know when to process the data on its input data line.
        if (load)
        begin
            if (type == EVEN_PARITY)
            begin
                parity_result_comb = ^(data_in);
            end
            else
            begin
                parity_result_comb = ~(^(data_in));
            end
        end
        else
        begin
            parity_result_comb = parity_result;
        end
    end
    
endmodule
