module serializer(
  input wire [7:0] data_in,
  input wire load,
  input wire enable,
  input wire clk,
  input wire rst,
  output reg done,
  output reg data_out
  );
  
  reg [7:0] shift_register;
  reg [2:0] counter, counter_comb;
  
  // The load signal let the serializer block know when to capture the data on its input data line.
  always@(posedge clk or negedge rst or posedge load)
    begin
      if(!rst)
        begin
          shift_register <= 'd0;
        end
      else if(load)
        begin
          shift_register <= data_in;
        end
      else if(enable)
        begin
          shift_register <= shift_register >> 1;
        end
    end
    
  always@(*)
    begin
      data_out = shift_register[0];
    end
  
  // Counter sequential logic
  always@(posedge clk or negedge rst)
    begin
      if(!rst)
        begin
          counter <= 'd0;
        end
      else
        begin
          counter <= counter_comb;
        end
    end
    
  // Counter combinational logic
  always@(*)
    begin
      if(done == 1'b1)
        begin
          counter_comb = 'd0;
        end
      else if(enable)
        begin
          counter_comb = counter + 'd1;
        end
      else
        begin
    	     counter_comb = counter;    
        end
    end
    
  always@(*)
    begin
      if(counter == 'd7)
        begin
          done = 1'b1;
        end
      else
        begin
          done = 1'b0;
        end
    end
    
endmodule
