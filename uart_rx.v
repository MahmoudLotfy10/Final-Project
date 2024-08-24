`default_nettype wire

module uart_rx #(parameter data_width=8,prescale_width=6,no_of_bits_in_frame =11)(
    input wire clk_rx ,//
    input wire rst_rx ,//
    input wire RX_IN  ,//
    input wire [prescale_width-1:0] prescale,//
    input wire PAR_EN,//
    input wire PAR_TYP,//
    output wire [data_width-1:0] p_data,
    output wire data_valid,
    output wire stp_err,
    output wire par_err
    
);

    wire [3:0] bit_cnt_w;
    wire [prescale_width-1:0] edge_cnt_w;
    wire strt_glitch_w;
    wire data_samp_en_w;
    wire par_chk_en_w;
    wire strt_chk_en_w;
    wire stp_chk_en_w;
    wire edge_bit_counter_enable_w;
    wire deser_en_w;
    wire sampled_bit_w;
    

    fsm #(.prescale_width(prescale_width)) FSM (
    .clk(clk_rx),
    .rst(rst_rx),
    .RX_IN(RX_IN),
    .PAR_EN(PAR_EN),
    .bit_cnt(bit_cnt_w),
    .prescale(prescale),
    .edge_cnt(edge_cnt_w),
    .par_err(par_err),
    .strt_glitch(strt_glitch_w),
    .stp_err(stp_err),
    .data_samp_en(data_samp_en_w),
    .par_chk_en(par_chk_en_w),
    .strt_chk_en(strt_chk_en_w),
    .stp_chk_en(stp_chk_en_w),
    .edge_bit_counter_enable(edge_bit_counter_enable_w),
    .deser_en(deser_en_w),
    .data_valid(data_valid)
    

    );

    strt_check START_CHECK(
        .clk(clk_rx),
        .rst(rst_rx),
        .strt_chk_en(strt_chk_en_w),
        .strt_glitch(strt_glitch_w),
        .sampled_bit(sampled_bit_w)
     );

    stop_check STOP_CHECK(
        .clk(clk_rx),
        .rst(rst_rx),
        .stp_chk_en(stp_chk_en_w),
        .sampled_bit(sampled_bit_w),
        .stp_err(stp_err)

    ) ;

    parity_check PARITY_CHECK(
        .clk(clk_rx),
        .rst(rst_rx),
        .par_chk_en(par_chk_en_w),
        .sampled_bit(sampled_bit_w),
        .par_typ(PAR_TYP),
        .p_data(p_data),
        .par_err(par_err)

    );

    edge_bit_counter #(.prescale_width(prescale_width),.no_of_bits_in_frame(no_of_bits_in_frame)) EDGE_BIT_COUNTER(
        .clk(clk_rx),
        .rst(rst_rx),
        .PAR_EN(PAR_EN),
        .edge_bit_counter_enable(edge_bit_counter_enable_w),
        .prescale(prescale),
        .edge_cnt(edge_cnt_w),
        .bit_cnt(bit_cnt_w)
    );

    deserializer #(.data_width(data_width),.prescale_width(prescale_width)) DESERIALIZER(
        .clk(clk_rx),
        .rst(rst_rx),
        .sampled_bit(sampled_bit_w),
        .deser_en(deser_en_w),
        .prescale(prescale),
        .edge_cnt(edge_cnt_w),
        .p_data(p_data)
    );

    data_sampling #( .prescale_width(prescale_width)) DATA_SAMPLING(
        .clk(clk_rx),
        .rst(rst_rx),
        .RX_IN(RX_IN),
        .data_samp_en(data_samp_en_w),
        .prescale(prescale),
        .edge_cnt(edge_cnt_w),
        .sampled_bit(sampled_bit_w)
    );

endmodule