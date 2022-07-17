module Parity_Calc(
  input wire rst,
  input wire [7:0] data_in,
  input wire load,
  input wire type,
  output reg parity_result
  );
  
  localparam  EVEN_PARITY = 1'b0,
              ODD_PARITY  = 1'b1;
  
  reg [7:0] temp_reg;
              
  // The load signal let the parity calculator block know when to capture the data on its input data line.
  always@(posedge load or negedge rst)
    begin
      if(!rst)
        begin
          temp_reg <= 'd0;
        end
      else
        begin
          temp_reg <= data_in;
        end
    end
              
  always@(*)
    begin
      if(type == EVEN_PARITY)
        begin
          parity_result = ^(temp_reg);
        end
      else
        begin
          parity_result = ~(^(temp_reg));
        end
    end
  
endmodule
