module MUX_8x1(
  input wire [2:0] sel,
  input wire [7:0] data,
  output reg out
  );
              
  always@(*)
    begin
      out = data[sel];
    end
  
endmodule
