module deserializer #(parameter data_width=8,prescale_width=6)(
    input wire clk,
    input wire rst,
    input wire sampled_bit,
    input wire deser_en,
    input wire [prescale_width-1:0] prescale,
    input wire [prescale_width-1:0] edge_cnt,
    output reg [data_width-1:0] p_data
);
    
    always @(posedge clk , negedge rst) begin

        if(!rst)
        p_data <=0;

        else if (deser_en && (edge_cnt==(prescale-1)))
        p_data <= {p_data[data_width-2:0],sampled_bit};
        
        else
        p_data <= p_data;
    end

endmodule