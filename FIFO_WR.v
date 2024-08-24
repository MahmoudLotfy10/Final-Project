module FIFO_WR #(
    parameter P_WIDTH=4
) (
    input wclk,
    input wrst,
    input winc,
    input [P_WIDTH-1:0] wq2_rptr,
    output reg wfull,
    output [P_WIDTH-2:0] waddr,
    output reg [P_WIDTH-1:0] wptr
);

reg  [P_WIDTH-1:0] wbinary;
wire [P_WIDTH-1:0] w_gray_next,wbinary_next;

wire wfull_w;

always @(posedge wclk, negedge wrst) begin
    if(!wrst) begin
        wptr    <= 0;
        wbinary <= 0;
        wfull   <= 0;
    end
    else begin
        wbinary <= wbinary_next;
        wptr    <= w_gray_next ;
        wfull   <= wfull_w     ;
    end
end


assign waddr = wbinary [P_WIDTH-2:0];

assign wbinary_next = wbinary + (winc & !wfull);

gray_code_inversion #(.width(P_WIDTH))gray_binary_write
(
    .binary(wbinary_next),
    .gray(w_gray_next)

);

assign wfull_w = (w_gray_next[P_WIDTH-1]!=wq2_rptr[P_WIDTH-1]) && (w_gray_next[P_WIDTH-2]!=wq2_rptr[P_WIDTH-2]) && (w_gray_next[P_WIDTH-3:0]==wq2_rptr[P_WIDTH-3:0]);

endmodule
    
