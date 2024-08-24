module PRESCALE_MUX #(
    parameter prescale_width=6,out_width=8
) (
    input      [prescale_width-1:0] prescale,
    output reg [out_width-1:0]       mux_output
);
    always @(*) begin
        mux_output=1;
        case (prescale)

            6'b100000: mux_output=1;
            6'b010000: mux_output=2;
            6'b001000: mux_output=4;
            6'b000100: mux_output=8;

            default: mux_output=1;

        endcase
        
    end
endmodule