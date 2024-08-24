module data_sampling #(parameter prescale_width=6)
 (
    input wire clk,
    input wire rst,
    input wire RX_IN,
    input wire data_samp_en,
    input wire [prescale_width-1:0] prescale,
    input wire [prescale_width-1:0] edge_cnt,
    output reg sampled_bit 
);
    reg sampled_bit_t;
    wire sample_1,sample_2,sample_3;

    always @(posedge clk , negedge rst) begin
        
        if (!rst)
        sampled_bit <= 0;

        else if (data_samp_en)
        sampled_bit <= sampled_bit_t;

        else
        sampled_bit <= sampled_bit;

    end

 
    assign sample_1 = (edge_cnt==((prescale >>1 ) - 1)) ? RX_IN : sample_1;
    assign sample_2 = (edge_cnt==(prescale  >>1 ))      ? RX_IN : sample_2;
    assign sample_3 = (edge_cnt==((prescale >>1 ) + 1)) ? RX_IN : sample_3;
    
    always @(*) begin
        sampled_bit_t=0;

        if(sample_1 == sample_2)
        sampled_bit_t=sample_1;

        else if (sample_1 == sample_3)
        sampled_bit_t=sample_1;

        else if (sample_2 == sample_3)
        sampled_bit_t=sample_2;

        else
        sampled_bit_t = sampled_bit;
    end

endmodule