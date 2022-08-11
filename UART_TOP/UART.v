module UART(input wire TX_CLK,
            input wire RX_CLK,
            input wire RST,
            input wire PAR_TYP,
            input wire PAR_EN,
            input wire [7:0] P_DATA_TX,
            input wire DATA_VALID_TX,
            input wire RX_IN,
            input wire [5:0] PRESCALE_RX,
            output wire TX_OUT,
            output wire BUSY_TX,
            output wire [7:0] P_DATA_RX,
            output wire PAR_ERR_RX,
            output wire STP_ERR_RX,
            output wire DATA_VALID_RX);
    
     UART_Tx U0_UART_Tx (
    .CLK(TX_CLK),
    .RST(RST),
    .PAR_TYP(PAR_TYP),
    .PAR_EN(PAR_EN),
    .P_DATA(P_DATA_TX),
    .DATA_VALID(DATA_VALID_TX),
    .TX_OUT(TX_OUT),
    .Busy(BUSY_TX)
    );
    
     UART_Rx U1_UART_Rx (
    .RX_IN(RX_IN),
    .prescale(PRESCALE_RX),
    .PAR_TYP(PAR_TYP),
    .PAR_EN(PAR_EN),
    .CLK(RX_CLK),
    .RST(RST),
    .P_DATA(P_DATA_RX),
    .PAR_ERR(PAR_ERR_RX),
    .STP_ERR(STP_ERR_RX),
    .data_valid(DATA_VALID_RX)
    );
    
endmodule
