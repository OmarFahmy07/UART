module edge_bit_counter(input wire clock,
                        input wire reset,
                        input wire enable,
                        input wire [5:0] prescale,
                        output reg [5:0] edge_counter,
                        output reg [3:0] bit_counter);
    
    reg [5:0] edge_counter_comb;
    reg [3:0] bit_counter_comb;
    
    // Counters sequential logic
    always@(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            edge_counter <= 'd0;
            bit_counter  <= 'd0;
        end
        else
        begin
            edge_counter <= edge_counter_comb;
            bit_counter  <= bit_counter_comb;
        end
    end
    
    // Edge counter combinational logic
    always@(*)
    begin
        if (enable)
        begin
            if (edge_counter == prescale)
            begin
                edge_counter_comb = 'd1;
            end
            else
            begin
                edge_counter_comb = edge_counter + 'd1;
            end
        end
        else
        begin
            edge_counter_comb = 'd0;
        end
    end
    
    // Bit counter combinational logic
    always@(*)
    begin
        if (enable)
        begin
            if (bit_counter == 'd0)
            begin
                bit_counter_comb = 'd1;
            end
            else if (edge_counter == prescale)
            begin
                bit_counter_comb = bit_counter + 'd1;
            end
            else
            begin
                bit_counter_comb = bit_counter;
            end
        end
        else
        begin
            bit_counter_comb = 'd0;
        end
    end
    
endmodule
