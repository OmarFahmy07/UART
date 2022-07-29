module parity_check(input wire [7:0] data_in,
                    input wire parity_bit,
                    input wire enable,
                    input wire reset,
                    input wire load,
                    input wire parity_type,
                    output reg parity_error);

localparam EVEN_PARITY = 1'b0;
localparam ODD_PARITY  = 1'b1;

reg [7:0] temp_data_reg;
reg temp_parity_reg;

always@(posedge load or negedge reset)
begin
    if (!reset)
    begin
        temp_data_reg   <= 'd0;
        temp_parity_reg <= 1'b0;
    end
    else
    begin
        temp_data_reg   <= data_in;
        temp_parity_reg <= parity_bit;
    end
end

always@(*)
begin
    if (enable)
    begin
        case(parity_type)
            EVEN_PARITY:
            begin
                parity_error = ((^temp_data_reg) == temp_parity_reg) ? 1'b0 : 1'b1;
            end
            ODD_PARITY:
            begin
                parity_error = ((~^temp_data_reg) == temp_parity_reg) ? 1'b0 : 1'b1;
            end
        endcase
    end
    else
    begin
        parity_error = 1'b0;
    end
end

endmodule
