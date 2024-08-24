module SYSTEM_TOP #(
    //uart_top
        parameter data_width=8,prescale_width=6,no_of_bits_in_frame =11,
    //data_sync
        parameter NUM_STAGES_data_sync =3,
    //sys control
        parameter alU_width  = 16 ,
        parameter ALU_FUN_WIDTH=4,
        parameter ADDR_SIZE=4,
    //reg file
        parameter DEPTH_regfile = 16,ADDR_regfile = 4,
    //fifo
        parameter P_WIDTH    = 4  ,
        parameter debth_fifo = 8  ,
        parameter NUM_STAGES_fifo = 2 ,
    //clk_div
        parameter integer_width = 8,
    //rst_sync
        parameter NUM_STAGES_rst_sync=2,
    //mux of prescale
        parameter out_width=8



) (
    input REF_CLK,
    input UART_CLK,
    input RST,
    input RX_IN,
    output TX_OUT,
    output wire stp_err,
    output wire par_err
);

wire tx_clk,rx_clk,CLK_DIV_EN_w;
wire sync_rst_1;
RST_SYNC #(.NUM_STAGES(NUM_STAGES_rst_sync)) RST_SYNC_1
(
    .clk(REF_CLK),
    .rst(RST),
    .sync_rst(sync_rst_1)
);

wire sync_rst_2;
RST_SYNC #(.NUM_STAGES(NUM_STAGES_rst_sync)) RST_SYNC_2
(
    .clk(UART_CLK),
    .rst(RST),
    .sync_rst(sync_rst_2)
);
ClkDiv  #(.integer_width(integer_width)) CLKDIV_FOR_UART_TX
(   .i_ref_clk(UART_CLK),
    .i_rst_n(sync_rst_2),
    .i_clk_en(CLK_DIV_EN_w),
    .i_div_ratio(8'd32),
    .o_div_clk(tx_clk)

);

wire [integer_width-1:0] output_of_mux;
ClkDiv  #(.integer_width(integer_width)) CLKDIV_FOR_UART_RX
(   .i_ref_clk(UART_CLK),
    .i_rst_n(sync_rst_2),
    .i_clk_en(CLK_DIV_EN_w),
    .i_div_ratio(output_of_mux),
    .o_div_clk(rx_clk)

);

wire   [data_width-1:0]  REG0_w;
wire   [data_width-1:0]  REG1_w;
wire   [data_width-1:0]  REG2_w;
wire   [data_width-1:0]  REG3_w;
//wire [prescale_width-1:0] prescale_out_of_reg_file;
PRESCALE_MUX #(.prescale_width(prescale_width),.out_width(out_width)) MUX_OF_PRESCALE
(
    .prescale(REG2_w[7:2]),
    .mux_output(output_of_mux)
);



wire CLK_EN_OUT_OF_SYS_CNTRL,GATED_CLK_W;

CLK_GATE CLK_GATE0(
.CLK_EN(CLK_EN_OUT_OF_SYS_CNTRL),
.CLK(REF_CLK),
.GATED_CLK(GATED_CLK_W)
);

wire busy_w,RD_INC_W;

pulse_gen pulse_gen0(
.clk(tx_clk),
.rst(sync_rst_2),
.d(busy_w),
.pluse_generated(RD_INC_W)
);

wire EMPTY_W;
wire [data_width-1:0] RD_DATA_W;



  
wire [data_width-1:0] p_data_w;
wire data_valid_w;

UART_TOP #(.data_width(data_width),.prescale_width(prescale_width),.no_of_bits_in_frame(no_of_bits_in_frame)) UART
(
    .CLK_TX(tx_clk),
    .CLK_RX(rx_clk),
    .RST(sync_rst_2),
    .P_DATA(RD_DATA_W),
    .Data_Valid(!EMPTY_W),
    .parity_enable(REG2_w[0]),
    .parity_type(REG2_w[1]),
    .TX_OUT(TX_OUT),
    .busy(busy_w),

    .RX_IN(RX_IN),
    .prescale(REG2_w[7:2]),
    .p_data(p_data_w),
    .data_valid(data_valid_w),
    .stp_err(stp_err),
    .par_err(par_err)

);
    
wire [data_width-1:0] RX_P_DATA_w;
wire RX_DATA_VALID_w;

DATA_SYNC #(.NUM_STAGES(NUM_STAGES_data_sync),.BUS_WIDTH(data_width)) DATA_SYNC0
(
    .clk(REF_CLK),
    .rst(sync_rst_1),
    .unsync_bus(p_data_w),
    .bus_enable(data_valid_w),
    .sync_bus(RX_P_DATA_w),
    .enable_pulse(RX_DATA_VALID_w)
);

wire W_INC_w,FULL_W;
wire [data_width-1:0] WR_DATA_w;
ASYNC_FIFO #(.P_WIDTH(P_WIDTH),.debth(debth_fifo),.BUS_WIDTH(data_width),.NUM_STAGES(NUM_STAGES_fifo)) ASYNC_FIFO0
(
    .W_CLK(REF_CLK),
    .W_RST(sync_rst_1),
    .W_INC(W_INC_w),
    .R_CLK(tx_clk),
    .R_RST(sync_rst_2),
    .R_INC(RD_INC_W),
    .WR_DATA(WR_DATA_w),

    .FULL(FULL_W),
    .EMPTY(EMPTY_W),
    .RR_DATA(RD_DATA_W)

);

wire EN_w;
wire [ALU_FUN_WIDTH-1:0]  ALU_FUN_w;
wire [alU_width-1:0]  ALU_OUT_w;
wire OUT_VALID_w ;
ALU #(.OPER_WIDTH(data_width),.OUT_WIDTH(alU_width)) ALU0
(
    .CLK(GATED_CLK_W),
    .RST(sync_rst_1),
    .A(REG0_w),
    .B(REG1_w),
    .EN(EN_w),
    .ALU_FUN(ALU_FUN_w),
    .ALU_OUT(ALU_OUT_w),
    .OUT_VALID(OUT_VALID_w)

);

wire   [ADDR_regfile-1:0]   Address_w;
wire   [data_width-1:0]  WrData_w;
wire   [data_width-1:0]  RdData_w;
wire   RdData_VLD_w;

RegFile #(.WIDTH(data_width),.DEPTH(DEPTH_regfile),.ADDR(ADDR_regfile)) RegFile0

(
    .CLK(REF_CLK),
    .RST(sync_rst_1),
    .WrEn(WrEn_w),
    .RdEn(RdEn_w),
    .Address(Address_w),
    .WrData(WrData_w),
    .RdData(RdData_w),
    .RdData_VLD(RdData_VLD_w),
    .REG0(REG0_w),
    .REG1(REG1_w),
    .REG2(REG2_w),
    .REG3(REG3_w)
);


SYS_CNTRL #(.alU_width(alU_width),.data_width(data_width),.ALU_FUN_WIDTH(ALU_FUN_WIDTH),.ADDR_SIZE(ADDR_SIZE)) SYS_CNTRL0
(
    .CLK(REF_CLK),
    .RST(sync_rst_1),
    .ALU_OUT(ALU_OUT_w),
    .OUT_VALID(OUT_VALID_w),
    .RX_P_DATA(RX_P_DATA_w),
    .RX_DATA_VALID(RX_DATA_VALID_w),
    .RDDATA(RdData_w),
    .RDDATA_VALID(RdData_VLD_w),
    .fifo_full(FULL_W),
    .ALU_EN(EN_w),
    .ALU_FUN(ALU_FUN_w),
    .CLK_EN(CLK_EN_OUT_OF_SYS_CNTRL),
    .Address(Address_w),
    .WREN(WrEn_w),
    .RDEN(RdEn_w),
    .WR_D(WrData_w),
    .WR_DATA(WR_DATA_w),
    .W_INC(W_INC_w),
    .CLK_DIV_EN(CLK_DIV_EN_w)


);

endmodule