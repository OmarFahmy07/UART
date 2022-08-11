module UART_Rx(input wire RX_IN,
               input wire [5:0] prescale,
               input wire PAR_EN,
               input wire PAR_TYP,
               input wire CLK,
               input wire RST,
               output wire [7:0] P_DATA,
               output wire PAR_ERR,
               output wire STP_ERR,
               output wire data_valid);
    
    wire [3:0] bit_counter;
    wire [5:0] edge_counter;
    wire start_glitch;
    wire counter_en, deserializer_en, start_check_en, parity_check_en, stop_check_en;
    wire sampler_output;
    
    UART_Rx_FSM U0_FSM (
    .clock(CLK),
    .reset(RST),
    .data_in(RX_IN),
    .parity_en(PAR_EN),
    .bit_counter(bit_counter),
    .edge_counter(edge_counter),
    .prescale(prescale),
    .start_glitch(start_glitch),
    .parity_error(PAR_ERR),
    .stop_error(STP_ERR),
    .counter_en(counter_en),
    .deserializer_en(deserializer_en),
    .start_check_en(start_check_en),
    .parity_check_en(parity_check_en),
    .stop_check_en(stop_check_en),
    .data_valid(data_valid));
    
    data_sampling U1_Sampler(
    .clock(CLK),
    .reset(RST),
    .edge_counter(edge_counter),
    .data_in(RX_IN),
    .prescale(prescale),
    .data_out(sampler_output));
    
    deserializer U2_Deserializer(
    .clock(CLK),
    .enable(deserializer_en),
    .reset(RST),
    .data_in(sampler_output),
    .shift_reg(P_DATA));
    
    edge_bit_counter U3_Counter(
    .clock(CLK),
    .reset(RST),
    .enable(counter_en),
    .prescale(prescale),
    .edge_counter(edge_counter),
    .bit_counter(bit_counter));
    
    parity_check U4_Parity(
    .reset(RST),
    .data_in(P_DATA),
    .parity_bit(sampler_output),
    .clock(CLK),
    .enable(parity_check_en),
    .parity_type(PAR_TYP),
    .parity_error(PAR_ERR));
    
    start_check U5_Start(
    .clock(CLK),
    .reset(RST),
    .data_in(sampler_output),
    .enable(start_check_en),
    .glitch(start_glitch));
    
    stop_check U6_Stop(
    .data_in(sampler_output),
    .enable(stop_check_en),
    .clock(CLK),
    .reset(RST),
    .stop_error(STP_ERR));
    
endmodule
