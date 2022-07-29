module UART_Rx_FSM (input wire clock,
                    input wire reset,
                    input wire data_in,
                    input wire parity_en,
                    input wire [3:0] bit_counter,
                    input wire [5:0] edge_counter,
                    input wire [5:0] prescale,
                    input wire start_glitch,
                    input wire parity_error,
                    input wire stop_error,
                    output wire counter_en,
                    output wire deserializer_en,
                    output wire start_check_en,
                    output wire parity_check_en,
                    output wire parity_check_load,
                    output wire stop_check_en,
                    output wire stop_check_load,
                    output reg data_valid);
    
    // States encoding - gray encode is used to reduce switching power
    localparam IDLE   = 3'b000;
    localparam START  = 3'b001;
    localparam DATA   = 3'b011;
    localparam PARITY = 3'b010;
    localparam STOP   = 3'b110;
    localparam OUTPUT = 3'b100;
    
    reg [2:0] current_state, next_state;
    
    wire [5:0] third_sample_edge, stable_sampled_value_edge;
    
    // Current state sequential logic
    always @(posedge clock or negedge reset)
    begin
        if (!reset)
        begin
            current_state <= IDLE;
        end
        else
        begin
            current_state <= next_state;
        end
    end
    
    // Next state combinational logic
    always @(*)
    begin
        // Initial value to avoid unintentional latches
        next_state = IDLE;
        case(current_state)
            IDLE:
            begin
                // If a start bit is detected, go to the START state
                if (data_in == 1'b0)
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
                /* Wait until the start bit is sampled by the data sampling block. The start check block
                 should then tell you whether it is a true start bit or just a glitch. If it was a glitch,
                 return immediately after detecting the glitch to the idle state. Otherwise, it is a true
                 start bit and hence wait for the whole Tx clock cycle and then go to the DATA state. */
                if ((edge_counter == third_sample_edge) && start_glitch)
                begin
                    next_state = IDLE;
                end
                else if (edge_counter == prescale)
                begin
                    next_state = DATA;
                end
                else
                begin
                    next_state = current_state;
                end
            end
            DATA:
            begin
                /* Wait until the whole 8 data bits are sampled and their full Tx clock cycles have
                 passed, then go to either the PARITY or STOP state depending on the parity enable */
                if ((bit_counter == 'd9) && (edge_counter == prescale))
                begin
                    if (parity_en)
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
                /* Wait until a full Tx clock cycle passes, then go to the STOP state */
                if (edge_counter == prescale)
                begin
                    next_state = STOP;
                end
                else
                begin
                    next_state = current_state;
                end
            end
            STOP:
            begin
                /* The OUTPUT state should be a 1-clock-cycle state immediately after the STOP state.*/
                if (edge_counter == (prescale - 'd1))
                begin
                    next_state = OUTPUT;
                end
                else
                begin
                    next_state = current_state;
                end
            end
            OUTPUT:
            begin
                /* In case a start bit is detected, this means that 2 consecutive frames are received.
                 Accordingly, go to the START state. Otherwise, return to the idle state */
                if (data_in == 1'b0)
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
    
    /* Output Logic. Either there is a stop error or parit error so one or both of them are high, or both
     are 0 and hence data valid is high. This output is active for 1 Rx clock cycle */
    always@(*)
    begin
        if (current_state == OUTPUT)
        begin
            if (parity_en)
            begin
                if (!parity_error && !stop_error)
                begin
                    data_valid = 1'b1;
                end
                else
                begin
                    data_valid = 1'b0;
                end
            end
            else
            begin
                if (!stop_error)
                begin
                    data_valid = 1'b1;
                end
                else
                begin
                    data_valid = 1'b0;
                end
            end
        end
        else
        begin
            data_valid = 1'b0;
        end
    end
    
    /* The counters are not needed in both idle and output states. Otherwise, the counters are always
     enabled */
    assign counter_en = ((next_state == IDLE) || (next_state == OUTPUT)) ? 1'b0 : 1'b1;
    
    /* Deserializer is used to extract data bits, so it should be enabled only in the DATA state.
     Moreover, it should be enabled only after the data sampling block's output has stabilized so that the
     deserializer block takes in the correct sample of the data bits */
    assign deserializer_en = ((current_state == DATA) && (edge_counter == stable_sampled_value_edge)) ? 1'b1 : 1'b0;
    
    /* The start check block is used to check that a detected start bit is valid. Enable the start check
     block after the data sampling block has successfully sampled the start bit so that the start check
     block takes in the correct sample of the start bit */
    assign start_check_en = ((current_state == START) && (edge_counter == third_sample_edge)) ? 1'b1 : 1'b0;
    
    /* Parity check block is used to compute the parity of the received data byte and compare it with the
     parity bit in the frame. The parity error signal is observed in the OUTPUT state, so the parity check
     block should be enabled in the OUTPUT state. */
    assign parity_check_en = (current_state == OUTPUT) ? 1'b1 : 1'b0 ;
    
    /* Stop check block is used to check that a detected stop bit is valid. The stop error signal is
     observed in the OUTPUT state, so the stop check block should be enabled in the OUTPUT state. */
    assign stop_check_en = (current_state == OUTPUT) ? 1'b1 : 1'b0 ;
    
    /* The parity check block should be loaded after the data sampling block's output has stabilized so
     that the parity check block takes in the correct sample of the parity bit */
    assign parity_check_load = ((current_state == PARITY) && (edge_counter == stable_sampled_value_edge)) ? 1'b1 : 1'b0;
    
    /* The stop check block should be loaded after the data sampling block's output has stabilized so
     that the stop check block takes in the correct sample of the stop bit */
    assign stop_check_load = ((current_state == STOP) && (edge_counter == stable_sampled_value_edge)) ? 1'b1 : 1'b0;
    
    /* The data sampler block takes 3 samples at the 3 middle clock edges of a Tx clock cycle. The third
     edge at which the sampler takes the third sample is frequently needed in the code since the output of
     the sampler is evaluated at this edge, so a dedicated assign statement is used to shorten the code and
     make it more readable. That third edge is obtained by simply dividing the "prescale" value by 2 then
     add 1. Instead of dividing by 2, we will use shifting in order to save area since a divider consumes
     large area. */
    assign third_sample_edge = (prescale >> 1) + 'd1;
    
    /* The data sampler block takes 3 samples at the 3 middle clock edges of a Tx clock cycle. The fourth
     edge at which the sampler's output is ready is frequently needed in the code since the output of
     the sampler is stable at this edge, so a dedicated assign statement is used to shorten the code and
     make it more readable. That fourth edge is obtained by simply dividing the "prescale" value by 2 then
     add 1. Instead of dividing by 2, we will use shifting in order to save area since a divider consumes
     large area. */
    assign stable_sampled_value_edge = (prescale >> 1) + 'd2;
    
endmodule
