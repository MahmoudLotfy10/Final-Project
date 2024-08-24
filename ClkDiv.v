module ClkDiv #(parameter integer_width = 8)(
    input wire i_ref_clk,
    input wire i_rst_n,
    input wire i_clk_en,
    input wire [integer_width-1:0] i_div_ratio,
    output wire o_div_clk
);

reg o_div_clk_t;

wire isodd;
reg first_time;
reg [integer_width-1:0] counter;
wire [integer_width-1:0] i_div_ratio_divide_by_two;
wire [integer_width-1:0] remain_of_odd;
wire high_o_clk;
wire even_condition;
wire odd_condition;
wire enable_condition;



always @(posedge i_ref_clk , negedge i_rst_n) begin

    if(!i_rst_n)begin
        o_div_clk_t  <= 0;
        first_time <= 1;
        counter    <= 0;
    end

    else if (enable_condition) begin

       if(first_time)begin
                o_div_clk_t<=~o_div_clk_t;
                first_time<=0;
                counter<=counter+1;
            end

       else if(even_condition)begin
                counter<=1;
                o_div_clk_t<=~o_div_clk_t;
        end
            
        else if(odd_condition) begin
                counter<=1;
                o_div_clk_t<=~o_div_clk_t;
            end

        else begin
                counter<=counter+1;
            end   
    end

    else begin
        o_div_clk_t <= i_ref_clk;
    end

end



assign high_o_clk=o_div_clk_t;
assign i_div_ratio_divide_by_two = i_div_ratio >> 1;
assign isodd = i_div_ratio[0];
assign remain_of_odd=i_div_ratio-i_div_ratio_divide_by_two;

assign even_condition   = (!isodd) && (counter==i_div_ratio_divide_by_two);
assign odd_condition    = (isodd && counter==i_div_ratio_divide_by_two && high_o_clk)||(isodd &&counter==remain_of_odd && !high_o_clk);
assign enable_condition = (i_clk_en) && (i_div_ratio != 0) && (i_div_ratio != 1);

assign o_div_clk = enable_condition ? o_div_clk_t : i_ref_clk;

endmodule