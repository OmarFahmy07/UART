module data_sampling(input wire clock,
                     input wire reset,
                     input wire [5:0] edge_counter,
                     input wire data_in,
                     input wire [5:0] prescale,
                     output wire data_out);
    
    reg sample1, sample2, sample3;
    reg sample1_comb, sample2_comb, sample3_comb;
    
    // Samples sequential logic
    always@(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            sample1 <= 1'b0;
            sample2 <= 1'b0;
            sample3 <= 1'b0;
        end
        else
        begin
            sample1 <= sample1_comb;
            sample2 <= sample2_comb;
            sample3 <= sample3_comb;
        end
    end
    
    // Sample 1 combinational logic
    always@(*)
    begin
        /* The data sampler block takes 3 samples at the 3 middle clock edges of a Tx clock cycle. Sample
         1 is before the edge in the middle. The edge in the middle is obtained by simply dividing the
         "prescale" value by 2. Instead of dividing by 2, we will use shifting in order to save area since
         a divider consumes large area. */
        if (edge_counter == ((prescale >> 1) - 'd2))
        begin
            sample1_comb = data_in;
        end
        else
        begin
            sample1_comb = sample1;
        end
    end
    
    // Sample 2 combinational logic
    always@(*)
    begin
        /* The data sampler block takes 3 samples at the 3 middle clock edges of a Tx clock cycle. Sample
         2 (i.e. the middle sample) is obtained by simply dividing the "prescale" value by 2. Instead of
         dividing by 2, we will use shifting in order to save area since a divider consumes large area. */
        if (edge_counter == ((prescale >> 1) - 'd1))
        begin
            sample2_comb = data_in;
        end
        else
        begin
            sample2_comb = sample2;
        end
    end
    
    // Sample 3 combinational logic
    always@(*)
    begin
        /* The data sampler block takes 3 samples at the 3 middle clock edges of a Tx clock cycle. Sample
         3 is after the edge in the middle. The edge in the middle is obtained by simply dividing the
         "prescale" value by 2. Instead of dividing by 2, we will use shifting in order to save area since
         a divider consumes large area. */
        if (edge_counter == (prescale >> 1))
        begin
            sample3_comb = data_in;
        end
        else
        begin
            sample3_comb = sample3;
        end
    end
    
    /*
     Sample3     Sample2     Sample1  |       data_out
     0           0           0        |           0
     0           0           1        |           0
     0           1           0        |           0
     0           1           1        |           1
     1           0           0        |           0
     1           0           1        |           1
     1           1           0        |           1
     1           1           1        |           1
     */
    assign data_out = (sample1 & sample2) | (sample1 & sample3) | (sample2 & sample3);
    
endmodule
