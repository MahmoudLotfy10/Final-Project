module UART_TOP #(
    parameter data_width=8,prescale_width=6,no_of_bits_in_frame =11
) (
 input   wire                         CLK_TX,
 input   wire                         CLK_RX,
 input   wire                         RST,
 input   wire    [data_width-1:0]     P_DATA,
 input   wire                         Data_Valid,
 input   wire                         parity_enable,
 input   wire                         parity_type, 
 output  wire                         TX_OUT,
 output  wire                         busy,

 //////////////////////////////////////////
 input wire RX_IN  ,
 input wire [prescale_width-1:0] prescale,
 output wire [data_width-1:0] p_data,
 output wire data_valid,
 output wire stp_err,
 output wire par_err
);
    UART_TX #(.DATA_WIDTH(data_width)) UART__TX
    (
        .CLK(CLK_TX),
        .RST(RST),
        .P_DATA(P_DATA),
        .Data_Valid(Data_Valid),
        .parity_enable(parity_enable),
        .parity_type(parity_type),
        .TX_OUT(TX_OUT),
        .busy(busy)
    );

    uart_rx #(.data_width(data_width),.prescale_width(prescale_width),.no_of_bits_in_frame(no_of_bits_in_frame)) uart_rx0
    (
        .clk_rx(CLK_RX),
        .rst_rx(RST),
        .RX_IN(RX_IN),
        .prescale(prescale),
        .PAR_EN(parity_enable),
        .PAR_TYP(parity_type),
        .p_data(p_data),
        .data_valid(data_valid),
        .stp_err(stp_err),
        .par_err(par_err)
    );

endmodule