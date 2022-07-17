`timescale 1 ns / 1 ps

module UART_Tx_TOP_tb();
  
  reg CLK_tb;
  reg RST_tb;
  reg PAR_TYP_tb;
  reg PAR_EN_tb;
  reg [7:0] P_DATA_tb;
  reg DATA_VALID_tb;
  wire TX_OUT_tb;
  wire Busy_tb;
  
  // States encoding (gray encoding to reduce switching power)
  localparam  IDLE    = 3'b000,
              START   = 3'b001,
              DATA    = 3'b011,
              PARITY  = 3'b010,
              STOP    = 3'b110;
    
  localparam  idle_bit  = 1'b1,
              start_bit = 1'b0,
              stop_bit  = 1'b1;
  
  localparam  EVEN_PARITY = 1'b0,
              ODD_PARITY  = 1'b1;
              
  localparam Tperiod = 5;
  
  initial
    begin
      $dumpfile("UART_Tx_TOP.vcd");
      $dumpvars;
      
      // Initialization
      initialize();
      
      // Reset
      reset();
      
      #(2*Tperiod)
      
      // Test case 1: check that a frame with no parity is sent successfully
      test_case_1();
      
      #(2*Tperiod)
      
      // Test case 2: check that a frame with even parity (equal 1) is sent successfully
      test_case_2();
      
      #(2*Tperiod)
      
      // Test case 3: check that a frame with odd parity (equal 1) is sent successfully
      test_case_3();
      
      #(2*Tperiod)
      
      // Test case 4: check that a frame with even parity (equal 0) is sent successfully
      test_case_4();        
      
      #(2*Tperiod)
      
      // Test case 5: check that a frame with odd parity (equal 0) is sent successfully
      test_case_5();
      
      #(2*Tperiod)
      
      // Test case 6: chech that two frames can be transmitted consecutively without an idle state in between
      test_case_6();    
  
      #(2*Tperiod)
      
      // Test case 7: check that changing the input data while transmission does not affect the operation
      test_case_7();
      
      $finish;
      
    end
  
  // Clock Generator -- Frequency = 200 MHz
  always
    #(Tperiod/2.0) CLK_tb = ~CLK_tb;
  
  UART_Tx_TOP DUT(
  .CLK(CLK_tb), 
  .RST(RST_tb),
  .PAR_TYP(PAR_TYP_tb),
  .PAR_EN(PAR_EN_tb),
  .P_DATA(P_DATA_tb),
  .DATA_VALID(DATA_VALID_tb),
  .TX_OUT(TX_OUT_tb),
  .Busy(Busy_tb)
  );
  
  task initialize;
    begin
      CLK_tb = 1'b0;
      PAR_TYP_tb = EVEN_PARITY;
      PAR_EN_tb = 1'b0;
      P_DATA_tb = 'd0;
      DATA_VALID_tb = 1'b0;
    end
  endtask
  
  task reset;
    begin
      RST_tb = 1'b1;
      #1 RST_tb = 1'b0;
      #1 RST_tb = 1'b1;
    end
  endtask
  
  task test_case_1;
    begin
      $display("Test case 1 is running");
      PAR_EN_tb = 1'b0;
      P_DATA_tb = 8'b01101110;
      DATA_VALID_tb = 1'b1;
      @(posedge CLK_tb);
      #(Tperiod/2.0) 
      if( DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb )
        begin
          @(posedge CLK_tb);
          #(Tperiod/2.0)
          DATA_VALID_tb = 1'b0;
          // The start bit should have been transmitted now
          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
            begin
              @(posedge CLK_tb);
              #(Tperiod/2.0)
              // The LSB of data should have been transmitted now
              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                begin
                  @(posedge CLK_tb);
                  #(Tperiod/2.0)
                  // The second data bit should have been transmitted now
                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                    begin
                      @(posedge CLK_tb);
                      #(Tperiod/2.0)
                      // The third data bit should have been transmitted now
                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                        begin
                          @(posedge CLK_tb);
                          #(Tperiod/2.0)
                          // The fourth data bit should have been transmitted now
                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                            begin
                              @(posedge CLK_tb);
                              #(Tperiod/2.0)
                              // The fifth data bit should have been transmitted now
                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                begin
                                  @(posedge CLK_tb);
                                  #(Tperiod/2.0)
                                  // The sixth data bit should have been transmitted now
                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                    begin
                                      @(posedge CLK_tb);
                                      #(Tperiod/2.0)
                                    // The seventh data bit should have been transmitted now
                                    if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                      begin
                                        @(posedge CLK_tb);
                                        #(Tperiod/2.0)
                                        // The eighth data bit should have been transmitted now
                                        if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                          begin
                                            @(posedge CLK_tb);
                                            #(Tperiod/2.0)
                                            // The stop bit should have been transmitted now
                                            if(DUT.U0.current_state == IDLE && TX_OUT_tb == idle_bit && !Busy_tb)
                                              begin
                                                $display("Test case 1 passed");
                                              end
                                            else
                                              begin
                                                $display("Test case 1 failed");
                                              end
                                          end
                                        else
                                          begin
                                            $display("Test case 1 failed");
                                          end
                                      end
                                    else
                                      begin
                                        $display("Test case 1 failed");
                                      end
                                    end
                                  else
                                    begin
                                      $display("Test case 1 failed");
                                    end
                                end
                              else
                                begin
                                  $display("Test case 1 failed");
                                end
                            end
                          else
                            begin
                              $display("Test case 1 failed");
                            end
                        end
                      else
                        begin
                          $display("Test case 1 failed");
                        end
                    end
                  else
                    begin
                      $display("Test case 1 failed");
                    end
                end
              else
                begin
                  $display("Test case 1 failed");
                end
            end
          else
            begin
              $display("Test case 1 failed");
            end
        end
      else
        begin
          $display("Test case 1 failed");
        end
    end
  endtask
  
  task test_case_2;
    begin
      $display("Test case 2 is running");
      PAR_EN_tb = 1'b1;
      PAR_TYP_tb = EVEN_PARITY;
      P_DATA_tb = 8'b01101110;
      DATA_VALID_tb = 1'b1;
      @(posedge CLK_tb);
      #(Tperiod/2.0) 
      if( DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb )
        begin
          @(posedge CLK_tb);
          #(Tperiod/2.0)
          DATA_VALID_tb = 1'b0;
          // The start bit should have been transmitted now
          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
            begin
              @(posedge CLK_tb);
              #(Tperiod/2.0)
              // The LSB of data should have been transmitted now
              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                begin
                  @(posedge CLK_tb);
                  #(Tperiod/2.0)
                  // The second data bit should have been transmitted now
                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                    begin
                      @(posedge CLK_tb);
                      #(Tperiod/2.0)
                      // The third data bit should have been transmitted now
                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                        begin
                          @(posedge CLK_tb);
                          #(Tperiod/2.0)
                          // The fourth data bit should have been transmitted now
                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                            begin
                              @(posedge CLK_tb);
                              #(Tperiod/2.0)
                              // The fifth data bit should have been transmitted now
                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                begin
                                  @(posedge CLK_tb);
                                  #(Tperiod/2.0)
                                  // The sixth data bit should have been transmitted now
                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                    begin
                                      @(posedge CLK_tb);
                                      #(Tperiod/2.0)
                                    // The seventh data bit should have been transmitted now
                                    if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                      begin
                                        @(posedge CLK_tb);
                                        #(Tperiod/2.0)
                                        // The eighth data bit should have been transmitted now
                                        if(DUT.U0.current_state == PARITY && TX_OUT_tb == 1'b1 && Busy_tb)
                                          begin
                                            @(posedge CLK_tb);
                                            #(Tperiod/2.0)
                                            // The parity bit should have been transmitted now
                                            if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                              begin
                                                @(posedge CLK_tb);
                                                #(Tperiod/2.0)
                                                // The stop bit should have been transmitted now
                                                if(DUT.U0.current_state == IDLE && TX_OUT_tb == idle_bit && !Busy_tb)
                                                  begin
                                                    $display("Test case 2 passed");
                                                  end
                                                else
                                                  begin
                                                    $display("Test case 2 failed");
                                                  end
                                              end
                                            else
                                              begin
                                                $display("Test case 2 failed");
                                              end
                                          end
                                        else
                                          begin
                                            $display("Test case 2 failed");
                                          end
                                      end
                                    else
                                      begin
                                        $display("Test case 2 failed");
                                      end
                                    end
                                  else
                                    begin
                                      $display("Test case 2 failed");
                                    end
                                end
                              else
                                begin
                                  $display("Test case 2 failed");
                                end
                            end
                          else
                            begin
                              $display("Test case 2 failed");
                            end
                        end
                      else
                        begin
                          $display("Test case 2 failed");
                        end
                    end
                  else
                    begin
                      $display("Test case 2 failed");
                    end
                end
              else
                begin
                  $display("Test case 2 failed");
                end
            end
          else
            begin
              $display("Test case 2 failed");
            end
        end
      else
        begin
          $display("Test case 2 failed");
        end 
    end
  endtask
  
  
task test_case_3;
  begin
    $display("Test case 3 is running");
      PAR_EN_tb = 1'b1;
      PAR_TYP_tb = ODD_PARITY;
      P_DATA_tb = 8'b01101010;
      DATA_VALID_tb = 1'b1;
      @(posedge CLK_tb);
      #(Tperiod/2.0) 
      if( DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb )
        begin
          @(posedge CLK_tb);
          #(Tperiod/2.0)
          DATA_VALID_tb = 1'b0;
          // The start bit should have been transmitted now
          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
            begin
              @(posedge CLK_tb);
              #(Tperiod/2.0)
              // The LSB of data should have been transmitted now
              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                begin
                  @(posedge CLK_tb);
                  #(Tperiod/2.0)
                  // The second data bit should have been transmitted now
                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                    begin
                      @(posedge CLK_tb);
                      #(Tperiod/2.0)
                      // The third data bit should have been transmitted now
                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                        begin
                          @(posedge CLK_tb);
                          #(Tperiod/2.0)
                          // The fourth data bit should have been transmitted now
                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                            begin
                              @(posedge CLK_tb);
                              #(Tperiod/2.0)
                              // The fifth data bit should have been transmitted now
                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                begin
                                  @(posedge CLK_tb);
                                  #(Tperiod/2.0)
                                  // The sixth data bit should have been transmitted now
                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                    begin
                                      @(posedge CLK_tb);
                                      #(Tperiod/2.0)
                                    // The seventh data bit should have been transmitted now
                                    if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                      begin
                                        @(posedge CLK_tb);
                                        #(Tperiod/2.0)
                                        // The eighth data bit should have been transmitted now
                                        if(DUT.U0.current_state == PARITY && TX_OUT_tb == 1'b1 && Busy_tb)
                                          begin
                                            @(posedge CLK_tb);
                                            #(Tperiod/2.0)
                                            // The parity bit should have been transmitted now
                                            if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                              begin
                                                @(posedge CLK_tb);
                                                #(Tperiod/2.0)
                                                // The stop bit should have been transmitted now
                                                if(DUT.U0.current_state == IDLE && TX_OUT_tb == idle_bit && !Busy_tb)
                                                  begin
                                                    $display("Test case 3 passed");
                                                  end
                                                else
                                                  begin
                                                    $display("Test case 3 failed");
                                                  end
                                              end
                                            else
                                              begin
                                                $display("Test case 3 failed");
                                              end
                                          end
                                        else
                                          begin
                                            $display("Test case 3 failed");
                                          end
                                      end
                                    else
                                      begin
                                        $display("Test case 3 failed");
                                      end
                                    end
                                  else
                                    begin
                                      $display("Test case 3 failed");
                                    end
                                end
                              else
                                begin
                                  $display("Test case 3 failed");
                                end
                            end
                          else
                            begin
                              $display("Test case 3 failed");
                            end
                        end
                      else
                        begin
                          $display("Test case 3 failed");
                        end
                    end
                  else
                    begin
                      $display("Test case 3 failed");
                    end
                end
              else
                begin
                  $display("Test case 3 failed");
                end
            end
          else
            begin
              $display("Test case 3 failed");
            end
        end
      else
        begin
          $display("Test case 3 failed");
        end
  end
endtask

  task test_case_4;
    begin
      $display("Test case 4 is running");
      PAR_EN_tb = 1'b1;
      PAR_TYP_tb = EVEN_PARITY;
      P_DATA_tb = 8'b01101010;
      DATA_VALID_tb = 1'b1;
      @(posedge CLK_tb);
      #(Tperiod/2.0) 
      if( DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb )
        begin
          @(posedge CLK_tb);
          #(Tperiod/2.0)
          DATA_VALID_tb = 1'b0;
          // The start bit should have been transmitted now
          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
            begin
              @(posedge CLK_tb);
              #(Tperiod/2.0)
              // The LSB of data should have been transmitted now
              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                begin
                  @(posedge CLK_tb);
                  #(Tperiod/2.0)
                  // The second data bit should have been transmitted now
                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                    begin
                      @(posedge CLK_tb);
                      #(Tperiod/2.0)
                      // The third data bit should have been transmitted now
                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                        begin
                          @(posedge CLK_tb);
                          #(Tperiod/2.0)
                          // The fourth data bit should have been transmitted now
                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                            begin
                              @(posedge CLK_tb);
                              #(Tperiod/2.0)
                              // The fifth data bit should have been transmitted now
                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                begin
                                  @(posedge CLK_tb);
                                  #(Tperiod/2.0)
                                  // The sixth data bit should have been transmitted now
                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                    begin
                                      @(posedge CLK_tb);
                                      #(Tperiod/2.0)
                                    // The seventh data bit should have been transmitted now
                                    if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                      begin
                                        @(posedge CLK_tb);
                                        #(Tperiod/2.0)
                                        // The eighth data bit should have been transmitted now
                                        if(DUT.U0.current_state == PARITY && TX_OUT_tb == 1'b0 && Busy_tb)
                                          begin
                                            @(posedge CLK_tb);
                                            #(Tperiod/2.0)
                                            // The parity bit should have been transmitted now
                                            if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                              begin
                                                @(posedge CLK_tb);
                                                #(Tperiod/2.0)
                                                // The stop bit should have been transmitted now
                                                if(DUT.U0.current_state == IDLE && TX_OUT_tb == idle_bit && !Busy_tb)
                                                  begin
                                                    $display("Test case 4 passed");
                                                  end
                                                else
                                                  begin
                                                    $display("Test case 4 failed");
                                                  end
                                              end
                                            else
                                              begin
                                                $display("Test case 4 failed");
                                              end
                                          end
                                        else
                                          begin
                                            $display("Test case 4 failed");
                                          end
                                      end
                                    else
                                      begin
                                        $display("Test case 4 failed");
                                      end
                                    end
                                  else
                                    begin
                                      $display("Test case 4 failed");
                                    end
                                end
                              else
                                begin
                                  $display("Test case 4 failed");
                                end
                            end
                          else
                            begin
                              $display("Test case 4 failed");
                            end
                        end
                      else
                        begin
                          $display("Test case 4 failed");
                        end
                    end
                  else
                    begin
                      $display("Test case 4 failed");
                    end
                end
              else
                begin
                  $display("Test case 4 failed");
                end
            end
          else
            begin
              $display("Test case 4 failed");
            end
        end
      else
        begin
          $display("Test case 4 failed");
        end
    end
  endtask
  
  task test_case_5;
    begin
      $display("Test case 3 is running");
      PAR_EN_tb = 1'b1;
      PAR_TYP_tb = ODD_PARITY;
      P_DATA_tb = 8'b01101110;
      DATA_VALID_tb = 1'b1;
      @(posedge CLK_tb);
      #(Tperiod/2.0) 
      if( DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb )
        begin
          @(posedge CLK_tb);
          #(Tperiod/2.0)
          DATA_VALID_tb = 1'b0;
          // The start bit should have been transmitted now
          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
            begin
              @(posedge CLK_tb);
              #(Tperiod/2.0)
              // The LSB of data should have been transmitted now
              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                begin
                  @(posedge CLK_tb);
                  #(Tperiod/2.0)
                  // The second data bit should have been transmitted now
                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                    begin
                      @(posedge CLK_tb);
                      #(Tperiod/2.0)
                      // The third data bit should have been transmitted now
                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                        begin
                          @(posedge CLK_tb);
                          #(Tperiod/2.0)
                          // The fourth data bit should have been transmitted now
                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                            begin
                              @(posedge CLK_tb);
                              #(Tperiod/2.0)
                              // The fifth data bit should have been transmitted now
                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                begin
                                  @(posedge CLK_tb);
                                  #(Tperiod/2.0)
                                  // The sixth data bit should have been transmitted now
                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                    begin
                                      @(posedge CLK_tb);
                                      #(Tperiod/2.0)
                                    // The seventh data bit should have been transmitted now
                                    if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                      begin
                                        @(posedge CLK_tb);
                                        #(Tperiod/2.0)
                                        // The eighth data bit should have been transmitted now
                                        if(DUT.U0.current_state == PARITY && TX_OUT_tb == 1'b0 && Busy_tb)
                                          begin
                                            @(posedge CLK_tb);
                                            #(Tperiod/2.0)
                                            // The parity bit should have been transmitted now
                                            if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                              begin
                                                @(posedge CLK_tb);
                                                #(Tperiod/2.0)
                                                // The stop bit should have been transmitted now
                                                if(DUT.U0.current_state == IDLE && TX_OUT_tb == idle_bit && !Busy_tb)
                                                  begin
                                                    $display("Test case 5 passed");
                                                  end
                                                else
                                                  begin
                                                    $display("Test case 5 failed");
                                                  end
                                              end
                                            else
                                              begin
                                                $display("Test case 5 failed");
                                              end
                                          end
                                        else
                                          begin
                                            $display("Test case 5 failed");
                                          end
                                      end
                                    else
                                      begin
                                        $display("Test case 5 failed");
                                      end
                                    end
                                  else
                                    begin
                                      $display("Test case 5 failed");
                                    end
                                end
                              else
                                begin
                                  $display("Test case 5 failed");
                                end
                            end
                          else
                            begin
                              $display("Test case 5 failed");
                            end
                        end
                      else
                        begin
                          $display("Test case 5 failed");
                        end
                    end
                  else
                    begin
                      $display("Test case 5 failed");
                    end
                end
              else
                begin
                  $display("Test case 5 failed");
                end
            end
          else
            begin
              $display("Test case 5 failed");
            end
        end
      else
        begin
          $display("Test case 5 failed");
        end
    end
  endtask
  
  task test_case_6;
    begin
      $display("Test case 6 is running");
      PAR_EN_tb = 1'b0;
      P_DATA_tb = 8'b01101110;
      DATA_VALID_tb = 1'b1;
      @(posedge CLK_tb);
      #(Tperiod/2.0) 
      if( DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb )
        begin
          @(posedge CLK_tb);
          #(Tperiod/2.0)
          DATA_VALID_tb = 1'b0;
          // The start bit should have been transmitted now
          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
            begin
              @(posedge CLK_tb);
              #(Tperiod/2.0)
              // The LSB of data should have been transmitted now
              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                begin
                  @(posedge CLK_tb);
                  #(Tperiod/2.0)
                  // The second data bit should have been transmitted now
                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                    begin
                      @(posedge CLK_tb);
                      #(Tperiod/2.0)
                      // The third data bit should have been transmitted now
                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                        begin
                          @(posedge CLK_tb);
                          #(Tperiod/2.0)
                          // The fourth data bit should have been transmitted now
                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                            begin
                              @(posedge CLK_tb);
                              #(Tperiod/2.0)
                              // The fifth data bit should have been transmitted now
                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                begin
                                  @(posedge CLK_tb);
                                  #(Tperiod/2.0)
                                  // The sixth data bit should have been transmitted now
                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                    begin
                                      @(posedge CLK_tb);
                                      #(Tperiod/2.0)
                                      // The seventh data bit should have been transmitted now
                                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                        begin
                                          @(posedge CLK_tb);
                                          #(Tperiod/2.0)
                                          // Prepare new frame to check whether it will immediately be sent or not
                                          P_DATA_tb = 8'b11110110;
                                          PAR_EN_tb = 1'b0;
                                          DATA_VALID_tb = 1'b1;
                                          // The eighth data bit should have been transmitted now
                                          if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                            begin
                                              @(posedge CLK_tb);
                                              #(Tperiod/2.0)
                                              // The stop bit should have been transmitted now
                                              if(DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb)
                                                begin
                                                  @(posedge CLK_tb);
                                                  #(Tperiod/2.0)
                                                  DATA_VALID_tb = 1'b0;
                                                  // The start bit should have been transmitted now
                                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                                    begin
                                                      @(posedge CLK_tb);
  	                                                   #(Tperiod/2.0)
                                                      // The LSB of data should have been transmitted now
                                                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                                        begin
                                                          @(posedge CLK_tb);
                                                          #(Tperiod/2.0)
                                                          // The second data bit should have been transmitted now
                                                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                                            begin
                                                              @(posedge CLK_tb);
                                                              #(Tperiod/2.0)
                                                              // The third data bit should have been transmitted now
                                                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                                                begin
                                                                  @(posedge CLK_tb);
                                                                  #(Tperiod/2.0)
                                                                  // The fourth data bit should have been transmitted now
                                                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                                                    begin
                                                                      @(posedge CLK_tb);
                                                                      #(Tperiod/2.0)
                                                                      // The fifth data bit should have been transmitted now
                                                                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                                                        begin
                                                                          @(posedge CLK_tb);
                                                                          #(Tperiod/2.0)
                                                                          // The sixth data bit should have been transmitted now
                                                                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                                                            begin
                                                                              @(posedge CLK_tb);
                                                                              #(Tperiod/2.0)
                                                                            	 // The seventh data bit should have been transmitted now
                                                                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                                                                begin
                                                                                  @(posedge CLK_tb);
                                                                                  #(Tperiod/2.0)
                                                                                  // The eighth bit should have been transmitted now
                                                                                  if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                                                                    begin
                                                                                      @(posedge CLK_tb);
                                                                                    	 #(Tperiod/2.0)
                                                                                      // The stop bit should have been transmitted now
                                                                                      if(DUT.U0.current_state == IDLE && TX_OUT_tb == idle_bit &&  !Busy_tb)
                                                                                        begin
                                                                                          $display("Test case 6 passed");
                                                                                        end
                                                                                      else
                                                                                        begin
                                                                                          $display("Test case 6 failed");
                                                                                        end
                                                                                    end
                                                                                  else
                                                                                    begin
                                                                                      $display("Test case 6 failed");
                                                                                    end
                                                                                end
                                                                              else
                                                                                begin
                                                                                  $display("Test case 6 failed");
                                                                                end
                                                                            end
                                                                          else
                                                                            begin
                                                                              $display("Test case 6 failed");
                                                                            end
                                                                        end
                                                                      else
                                                                        begin
                                                                          $display("Test case 6 failed");
                                                                        end
                                                                    end
                                                                  else
                                                                    begin
                                                                      $display("Test case 6 failed");
                                                                    end
                                                                end
                                                              else
                                                                begin
                                                                  $display("Test case 6 failed");
                                                                end
                                                            end
                                                          else
                                                            begin
                                                              $display("Test case 6 failed");
                                                            end
                                                        end
                                                      else
                                                        begin
                                                          $display("Test case 6 failed");
                                                        end
                                                    end
                                                  else
                                                    begin
                                                      $display("Test case 6 failed");
                                                    end
                                                end
                                              else
                                                begin
                                                  $display("Test case 6 failed");
                                                end
                                            end
                                          else
                                            begin
                                              $display("Test case 6 failed");
                                            end
                                        end
                                      else
                                        begin
                                          $display("Test case 6 failed");
                                        end
                                    end
                                  else
                                    begin
                                      $display("Test case 6 failed");
                                    end
                                end
                              else
                                begin
                                  $display("Test case 6 failed");
                                end
                            end
                          else
                            begin
                              $display("Test case 6 failed");
                            end
                        end
                      else
                        begin
                          $display("Test case 6 failed");
                        end
                    end
                  else
                    begin
                      $display("Test case 6 failed");
                    end
                end
              else
                begin
                  $display("Test case 6 failed");
                end
            end
          else
            begin
              $display("Test case 6 failed");
            end
        end
      else
        begin
          $display("Test case 6 failed");
        end
    end
  endtask
  
  task test_case_7;
    begin
      $display("Test case 7 is running");
      PAR_EN_tb = 1'b0;
      P_DATA_tb = 8'b01101110;
      DATA_VALID_tb = 1'b1;
      @(posedge CLK_tb);
      #(Tperiod/2.0)
      P_DATA_tb = 8'b11101110; 
      if( DUT.U0.current_state == START && TX_OUT_tb == start_bit && Busy_tb )
        begin
          @(posedge CLK_tb);
          #(Tperiod/2.0)
          P_DATA_tb = 8'b10101111;
          DATA_VALID_tb = 1'b0;
          // The start bit should have been transmitted now
          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
            begin
              @(posedge CLK_tb);
              #(Tperiod/2.0)
              P_DATA_tb = 8'b01001110;
              // The LSB of data should have been transmitted now
              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                begin
                  @(posedge CLK_tb);
                  #(Tperiod/2.0)
                  P_DATA_tb = 8'b11111111;
                  // The second data bit should have been transmitted now
                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                    begin
                      @(posedge CLK_tb);
                      #(Tperiod/2.0)
                      P_DATA_tb = 8'b00000000;
                      // The third data bit should have been transmitted now
                      if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                        begin
                          @(posedge CLK_tb);
                          #(Tperiod/2.0)
                          P_DATA_tb = 8'b11100100;
                          // The fourth data bit should have been transmitted now
                          if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                            begin
                              @(posedge CLK_tb);
                              #(Tperiod/2.0)
                              P_DATA_tb = 8'b00001110;
                              // The fifth data bit should have been transmitted now
                              if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                begin
                                  @(posedge CLK_tb);
                                  #(Tperiod/2.0)
                                  P_DATA_tb = 8'b10011111;
                                  // The sixth data bit should have been transmitted now
                                  if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b1 && Busy_tb)
                                    begin
                                      @(posedge CLK_tb);
                                      #(Tperiod/2.0)
                                      P_DATA_tb = 8'b11101111;
                                    // The seventh data bit should have been transmitted now
                                    if(DUT.U0.current_state == DATA && TX_OUT_tb == 1'b0 && Busy_tb)
                                      begin
                                        @(posedge CLK_tb);
                                        #(Tperiod/2.0)
                                        P_DATA_tb = 8'b11001010;
                                        // The eighth data bit should have been transmitted now
                                        if(DUT.U0.current_state == STOP && TX_OUT_tb == stop_bit && Busy_tb)
                                          begin
                                            @(posedge CLK_tb);
                                            #(Tperiod/2.0)
                                            P_DATA_tb = 8'b11100000;
                                            // The stop bit should have been transmitted now
                                            if(DUT.U0.current_state == IDLE && TX_OUT_tb == idle_bit && !Busy_tb)
                                              begin
                                                $display("Test case 7 passed");
                                              end
                                            else
                                              begin
                                                $display("Test case 7 failed");
                                              end
                                          end
                                        else
                                          begin
                                            $display("Test case 7 failed");
                                          end
                                      end
                                    else
                                      begin
                                        $display("Test case 7 failed");
                                      end
                                    end
                                  else
                                    begin
                                      $display("Test case 7 failed");
                                    end
                                end
                              else
                                begin
                                  $display("Test case 7 failed");
                                end
                            end
                          else
                            begin
                              $display("Test case 7 failed");
                            end
                        end
                      else
                        begin
                          $display("Test case 7 failed");
                        end
                    end
                  else
                    begin
                      $display("Test case 7 failed");
                    end
                end
              else
                begin
                  $display("Test case 7 failed");
                end
            end
          else
            begin
              $display("Test case 7 failed");
            end
        end
      else
        begin
          $display("Test case 7 failed");
        end
    end
  endtask

  
endmodule
