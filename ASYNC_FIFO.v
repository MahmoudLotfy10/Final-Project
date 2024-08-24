module ASYNC_FIFO #(
    parameter P_WIDTH    = 4  ,
    parameter debth      = 8  ,
    parameter BUS_WIDTH  = 8 ,
    parameter NUM_STAGES = 2 
) (
    input W_CLK,
    input W_RST,
    input W_INC,
    input R_CLK,
    input R_RST,
    input R_INC,
    input [BUS_WIDTH-1:0] WR_DATA,

    output FULL,
    output EMPTY,
    output [BUS_WIDTH-1:0] RR_DATA
);
    
wire wclk_en_w;
wire [P_WIDTH-2:0] raddr_w;
wire [P_WIDTH-2:0] waddr_w;
assign wclk_en_w = W_INC && !FULL;

FIFO_MEM #(.BUS_WIDTH(BUS_WIDTH),.debth(debth),.P_WIDTH(P_WIDTH)) FIFO_Memory
(
    .wclk(W_CLK),
    .wrst(W_RST),
    .wclk_en(wclk_en_w),
    .wdata(WR_DATA),
    .rdata(RR_DATA),
    .raddr(raddr_w),
    .waddr(waddr_w)

);

wire [P_WIDTH-1:0] wq2_rptr_w;
wire [P_WIDTH-1:0] wptr_w;
FIFO_WR#(.P_WIDTH(P_WIDTH)) FIFO_Wptr_full
(
    .wclk(W_CLK),
    .wrst(W_RST),
    .winc(W_INC),
    .wq2_rptr(wq2_rptr_w),
    .wfull(FULL),
    .waddr(waddr_w),
    .wptr(wptr_w)
);

wire [P_WIDTH-1:0] rptr_w;

DF_SYNC #( .P_WIDTH(P_WIDTH),.NUM_STAGES(NUM_STAGES)) sync_r2w
(
    .clk(W_CLK),
    .rst(W_RST),
    .in(rptr_w),
    .out(wq2_rptr_w)
);

wire [P_WIDTH-1:0] rq2_wptr_w;
DF_SYNC #( .P_WIDTH(P_WIDTH),.NUM_STAGES(NUM_STAGES)) sync_w2r
(
    .clk(R_CLK),
    .rst(R_RST),
    .in(wptr_w),
    .out(rq2_wptr_w)
);

FIFO_RD #(.P_WIDTH(P_WIDTH)) FIFO_rptr_empty
(
    .rclk(R_CLK),
    .rrst(R_RST),
    .rinc(R_INC),
    .rq2_rptr(rq2_wptr_w),
    .rempty(EMPTY),
    .raddr(raddr_w),
    .rptr(rptr_w)

);

endmodule