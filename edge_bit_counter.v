module edge_bit_counter#(parameter no_of_bits_in_frame =11,prescale_width=6) (
    input wire clk,
    input wire rst,
    input wire edge_bit_counter_enable,
    input wire [prescale_width-1:0] prescale,
    input wire PAR_EN,
    output reg [prescale_width-1:0] edge_cnt,
    output reg [3:0] bit_cnt
);
 
   always @(posedge clk , negedge rst) begin
    if(!rst)
    begin
        edge_cnt <= 0;
        bit_cnt  <= 0;
    end
    else if (edge_bit_counter_enable)
    begin
        if(edge_cnt < prescale)
        begin
            edge_cnt <= edge_cnt+1;
            if(edge_cnt==prescale-1)
            begin
                if(PAR_EN)begin
                if(bit_cnt==no_of_bits_in_frame)
                bit_cnt  <= 1;
                else
              bit_cnt  <= bit_cnt+1;  end
              else begin
                if(bit_cnt==no_of_bits_in_frame-1)
                bit_cnt  <= 1;
                else
              bit_cnt  <= bit_cnt+1;
              end
            end
            
        end
        else
        begin
            edge_cnt <= 1;
        end
    end
    else
    begin
        edge_cnt <= 0;
        bit_cnt  <= 0 ;
    end
   end 

endmodule