module parity_check(input wire [7:0] data_in,
                    input wire parity_bit,
                    input wire enable,
                    input wire clock,
                    input wire reset,
                    input wire parity_type,
                    output reg parity_error);

localparam EVEN_PARITY = 1'b0;
localparam ODD_PARITY  = 1'b1;

reg parity_error_comb;

always@(posedge clock or negedge reset)
begin
    if (!reset)
    begin
        parity_error <= 1'b0;
    end
    else
    begin
        parity_error <= parity_error_comb;
    end
end

always@(*)
begin
    if (enable)
    begin
        case(parity_type)
            EVEN_PARITY:
            begin
                parity_error_comb = ((^data_in) == parity_bit) ? 1'b0 : 1'b1;
            end
            ODD_PARITY:
            begin
                parity_error_comb = ((~^data_in) == parity_bit) ? 1'b0 : 1'b1;
            end
        endcase
    end
    else
    begin
        parity_error_comb = parity_error;
    end
end

endmodule
