/* Tx's frequency = 25 MHz
 Rx's frequencies = 200 MHz, 400 MHz, or 800 MHz according to the prescaler. To test a certain Rx's
 frequency, just change the local parameter PRESCALE in line 25 to the desired prescale option (8, 16, 32).
 */

`timescale 1 ps / 1 fs

module UART_Rx_tb();
    
    reg RX_IN_tb;
    reg [5:0] prescale_tb;
    reg PAR_EN_tb;
    reg PAR_TYP_tb;
    reg CLK_tb;
    reg RST_tb;
    wire [7:0] P_DATA_tb;
    wire PAR_ERR_tb;
    wire STP_ERR_tb;
    wire data_valid_tb;
    
    reg CLK_Tx_tb;
    
    reg [12:0] T_PERIOD_Rx;
    
    localparam PRESCALE = 6'd8;
    
    localparam IDLE   = 3'b000;
    localparam START  = 3'b001;
    localparam DATA   = 3'b011;
    localparam PARITY = 3'b010;
    localparam STOP   = 3'b110;
    localparam OUTPUT = 3'b100;
    
    localparam T_PERIOD_Tx = 16'd40000;
    
    localparam EVEN_PARITY = 1'b0,
    ODD_PARITY = 1'b1;
    
    reg [3:0] test_case_counter;
    
    initial begin
        $dumpfile("UART_Rx.vcd");
        $dumpvars;
        
        // Signals initialization
        initialization(PRESCALE);
        
        // Reset all blocks
        reset();
        
        /* Test case 1: Data byte = 11001101 and valid even parity. Expected output: P_DATA = 11001101,
         data_valid = 1, no parity error, and no stop error. */
        test_case1();
        
        /* Test case 2: Data byte = 11001101 and valid odd parity. Expected output: P_DATA = 11001101,
         data_valid = 1, no parity error, and no stop error. */
        test_case2();
        
        /* Test case 3: Data byte = 11001101 and valid even parity. Expected output: data_valid = 0,
         parity error, and no stop error. */
        test_case3();
        
        /* Test case 4: Data byte = 11001101 and invalid odd parity. Expected output: data_valid = 0,
         party error, and no stop error. */
        test_case4();
        
        /* Test case 5: Data byte = 11001101, valid even parity, and invalid stop bit. Expected output:
         data_valid = 0, no parity error, and stop error. */
        test_case5();
        
        /* Test case 6: Data byte = 11001101, invalid even parity, and invalid stop bit. Expected output:
         data_valid = 0, parity error, and stop error. */
        test_case6();
        
        /* Test case 7: Data byte = 11001101, invalid odd parity, and invalid stop bit. Expected output:
         data_valid = 0, parity error, and stop error. */
        test_case7();
        
        /* Test case 8: Data byte = 11001101 and no parity. Expected output: data_valid = 1, no parity
         error, and no stop error. */
        test_case8();
        
        /* Test case 9: Data byte = 11001101, no parity, and an invalid stop bit. Expected output:
         data_valid = 0, no parity error, and stop error. */
        test_case9();
        
        /* Test case 10: testing the start glitch. A start bit glitch is initiated. Expected output:
         the FSM returns to the idle state in the next Tx clock cycle instead of the data bits state. */
        test_case10();
        
        /* Test case 11: testing two consecutive received frames (i.e. stop bit followed by a start bit) */
        test_case11();
        
        $finish;
    end
    
    // Tx Clock
    always
    begin
    #(T_PERIOD_Tx / 2.0) CLK_Tx_tb = ~CLK_Tx_tb;
    end
    
    // Rx Clock
    always
    begin
    #(T_PERIOD_Rx / 2.0) CLK_tb = ~CLK_tb;
    end
    
    task initialization(
        input [5:0] prescale
        );
        begin
            test_case_counter = 'd0;
            CLK_Tx_tb         = 1'b1;
            CLK_tb            = 1'b1;
            RX_IN_tb          = 1'b1;
            T_PERIOD_Rx       = T_PERIOD_Tx / PRESCALE;
            prescale_tb       = PRESCALE;
        end
    endtask
    
    task reset;
        begin
            RST_tb    = 1'b1;
            #1 RST_tb = 1'b0;
            #1 RST_tb = 1'b1;
        end
    endtask
    
    /* Test case 1: Data byte = 11001101 and valid even parity. Expected output: P_DATA = 11001101,
     data_valid = 1, no parity error, and no stop error. */
    task test_case1;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b1;
            PAR_TYP_tb        = EVEN_PARITY;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Parity Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(DUT.U0_FSM.current_state == OUTPUT);
            #(T_PERIOD_Rx / 2.0);
            if ((PAR_ERR_tb == 1'b0) && (STP_ERR_tb == 1'b0) && (data_valid_tb == 1'b1) && (P_DATA_tb == 8'b11001101))
            begin
                $display("Test case 1 passed");
            end
            else
            begin
                $display("Test case 1 failed");
            end
            // Idle Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case2;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b1;
            PAR_TYP_tb        = ODD_PARITY;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Parity Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(DUT.U0_FSM.current_state == OUTPUT);
            #(T_PERIOD_Rx / 2.0);
            if ((PAR_ERR_tb == 1'b0) && (STP_ERR_tb == 1'b0) && (data_valid_tb == 1'b1) && (P_DATA_tb == 8'b11001101))
            begin
                $display("Test case 2 passed");
            end
            else
            begin
                $display("Test case 2 failed");
            end
            // Idle Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case3;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b1;
            PAR_TYP_tb        = EVEN_PARITY;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Parity Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(DUT.U0_FSM.current_state == OUTPUT);
            #(T_PERIOD_Rx / 2.0);
            if ((PAR_ERR_tb == 1'b1) && (STP_ERR_tb == 1'b0) && (data_valid_tb == 1'b0))
            begin
                $display("Test case 3 passed");
            end
            else
            begin
                $display("Test case 3 failed");
            end
            // Idle Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case4;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b1;
            PAR_TYP_tb        = ODD_PARITY;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Parity Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(DUT.U0_FSM.current_state == OUTPUT);
            #(T_PERIOD_Rx / 2.0);
            if ((PAR_ERR_tb == 1'b1) && (STP_ERR_tb == 1'b0) && (data_valid_tb == 1'b0))
            begin
                $display("Test case 4 passed");
            end
            else
            begin
                $display("Test case 4 failed");
            end
            // Idle Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case5;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b1;
            PAR_TYP_tb        = EVEN_PARITY;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Parity Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(DUT.U0_FSM.current_state == OUTPUT);
            // Idle bit
            RX_IN_tb = 1'b1;
            #(T_PERIOD_Rx / 2.0);
            if ((PAR_ERR_tb == 1'b0) && (STP_ERR_tb == 1'b1) && (data_valid_tb == 1'b0))
            begin
                $display("Test case 5 passed");
            end
            else
            begin
                $display("Test case 5 failed");
            end
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case6;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b1;
            PAR_TYP_tb        = EVEN_PARITY;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Parity Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(DUT.U0_FSM.current_state == OUTPUT);
            // Idle bit
            RX_IN_tb = 1'b1;
            #(T_PERIOD_Rx / 2.0);
            if ((PAR_ERR_tb == 1'b1) && (STP_ERR_tb == 1'b1) && (data_valid_tb == 1'b0))
            begin
                $display("Test case 6 passed");
            end
            else
            begin
                $display("Test case 6 failed");
            end
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case7;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b1;
            PAR_TYP_tb        = ODD_PARITY;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Parity Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(DUT.U0_FSM.current_state == OUTPUT);
            // Idle bit
            RX_IN_tb = 1'b1;
            #(T_PERIOD_Rx / 2.0);
            if ((PAR_ERR_tb == 1'b1) && (STP_ERR_tb == 1'b1) && (data_valid_tb == 1'b0))
            begin
                $display("Test case 7 passed");
            end
            else
            begin
                $display("Test case 7 failed");
            end
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case8;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b0;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(DUT.U0_FSM.current_state == OUTPUT);
            #(T_PERIOD_Rx / 2.0);
            if ((STP_ERR_tb == 1'b0) && (data_valid_tb == 1'b1) && (P_DATA_tb == 8'b11001101))
            begin
                $display("Test case 8 passed");
            end
            else
            begin
                $display("Test case 8 failed");
            end
            // Idle Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case9;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b0;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(DUT.U0_FSM.current_state == OUTPUT);
            // Idle bit
            RX_IN_tb = 1'b1;
            #(T_PERIOD_Rx / 2.0);
            if ((STP_ERR_tb == 1'b1) && (data_valid_tb == 1'b0))
            begin
                $display("Test case 9 passed");
            end
            else
            begin
                $display("Test case 9 failed");
            end
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    task test_case10;
        begin
            test_case_counter = test_case_counter + 'd1;
            // Glitched start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            repeat(3) @(posedge CLK_tb);
            RX_IN_tb = 1'b1;
            #(T_PERIOD_Tx);
            if (DUT.U0_FSM.current_state == IDLE)
            begin
                $display("Test case 10 passed");
            end
            else
            begin
                $display("Test case 10 failed");
            end
        end
    endtask
    
    task test_case11;
        begin
            test_case_counter = test_case_counter + 'd1;
            PAR_EN_tb         = 1'b0;
            // Start bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            // Assume the data byte is: 11001101
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            // Stop Bit
            @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
            @(DUT.U0_FSM.current_state == OUTPUT);
            #(T_PERIOD_Rx / 2.0);
            if ((STP_ERR_tb == 1'b0) && (data_valid_tb == 1'b1) && (P_DATA_tb == 8'b11001101))
            begin
                // Start bit
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
                // Assume the data byte is: 11001101
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b1;
                // Invalid Stop Bit
                @(posedge CLK_Tx_tb) RX_IN_tb = 1'b0;
                @(DUT.U0_FSM.current_state == OUTPUT);
                // Idle bit
                RX_IN_tb = 1'b1;
                #(T_PERIOD_Rx / 2.0);
                if ((STP_ERR_tb == 1'b1) && (data_valid_tb == 1'b0))
                begin
                    $display("Test case 11 passed");
                end
                else
                begin
                    $display("Test case 11 failed");
                end
            end
            else
            begin
                $display("Test case 11 failed");
            end
            #(T_PERIOD_Tx * 2);
        end
    endtask
    
    UART_Rx DUT(
    .RX_IN(RX_IN_tb),
    .prescale(prescale_tb),
    .PAR_EN(PAR_EN_tb),
    .PAR_TYP(PAR_TYP_tb),
    .CLK(CLK_tb),
    .RST(RST_tb),
    .P_DATA(P_DATA_tb),
    .PAR_ERR(PAR_ERR_tb),
    .STP_ERR(STP_ERR_tb),
    .data_valid(data_valid_tb));
    
endmodule
