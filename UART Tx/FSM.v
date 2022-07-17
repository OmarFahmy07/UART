module FSM(
  input wire Data_Valid,
  input wire PAR_EN,
  input wire ser_done,
  input wire clk,
  input wire rst,
  output reg ser_load,
  output reg ser_en,
  output reg parity_load,
  output reg [2:0] mux_sel,
  output reg busy
  );
  
  reg [2:0] current_state, next_state;
  
  // States encoding (gray encoding to reduce switching power)
  localparam  IDLE    = 3'b000,
              START   = 3'b001,
              DATA    = 3'b011,
              PARITY  = 3'b010,
              STOP    = 3'b110;
  
  // Current state sequential logic
  always@(posedge clk or negedge rst)
    begin
      if(!rst)
        begin
          current_state <= IDLE;
        end
      else
        begin
          current_state <= next_state;
        end
    end
  
  // Next state combinational logic
  always@(*)
    begin
      // Initial values to avoid unintentional latches
      next_state = IDLE;
      case(current_state)
        IDLE:
          begin
            if(Data_Valid)
              begin
                next_state = START;
              end
            else
              begin
                next_state = current_state;
              end
          end
        START:
          begin
            next_state = DATA;
          end
        DATA:
          begin
            if(ser_done)
              begin
                if(PAR_EN)
                  begin
                    next_state = PARITY;
                  end
                else
                  begin
                    next_state = STOP;
                  end
              end
            else
              begin
                next_state = current_state;
              end
          end
        PARITY:
          begin
            next_state = STOP;
          end
        STOP:
          begin
            if(Data_Valid)
              begin
                next_state = START;
              end
            else
              begin
                next_state = IDLE;
              end
          end
        default:
          begin
            next_state = IDLE;
          end
      endcase
    end
    
    // Logic for serializer and parity load control signals
    always@(*)
      begin
        if( (current_state == IDLE || current_state == STOP) && Data_Valid)
          begin
            ser_load = 1'b1;
            parity_load = 1'b1;
          end
        else
          begin
            ser_load = 1'b0;
            parity_load = 1'b0;
          end
      end
      
    // Logic for the serializer's enable control signal
    always@(*)
      begin
        if(current_state == DATA)
          begin
            ser_en = 1'b1;
          end
        else
          begin
            ser_en = 1'b0;
          end
      end
  
  // Output (busy) combinational logic
  always@(*)
    begin
      if(current_state == IDLE)
        begin
          busy = 1'b0;
        end
      else
        begin
          busy = 1'b1;
        end
    end
    
  // Output (mux_sel) combinational logic
  always@(*)
    begin
      mux_sel = current_state;
    end
  
endmodule
