module FIFO_RD #(
    parameter P_WIDTH=4
) (
    input rclk,
    input rrst,
    input rinc,
    input [P_WIDTH-1:0] rq2_rptr,
    output reg rempty,
    output [P_WIDTH-2:0] raddr,
    output reg [P_WIDTH-1:0] rptr
);

reg  [P_WIDTH-1:0] rbinary;
wire [P_WIDTH-1:0] r_gray_next,rbinary_next;

wire rempty_w;
assign rempty_w = (r_gray_next  == rq2_rptr);

always @(posedge rclk , negedge rrst) begin
    if(!rrst) begin
        rbinary <= 0;
        rptr    <= 0;
        rempty  <= 1;
    end
    else begin
        rbinary <= rbinary_next;
        rptr    <= r_gray_next;
        rempty  <= rempty_w;
    end
end
 assign raddr = rbinary [P_WIDTH-2:0];

 assign  rbinary_next = rbinary + (rinc & !rempty);


 gray_code_inversion #(.width(P_WIDTH))gray_binary_read
(
    .binary(rbinary_next),
    .gray(r_gray_next)

);


endmodule