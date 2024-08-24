module stop_check (
    input wire clk,
    input wire rst,
    input wire stp_chk_en,
    input wire sampled_bit,
    output reg stp_err
);
wire stp_err_t;

always @(posedge clk , negedge rst) begin
    if(!rst)
    stp_err <= 0;
    else if (stp_chk_en)
    stp_err <= stp_err_t;
    else
    stp_err <= stp_err;
end

assign stp_err_t = (sampled_bit==1) ? 0 : 1 ;

endmodule