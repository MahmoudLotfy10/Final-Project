module strt_check (
    input wire clk,
    input wire rst,
    input wire strt_chk_en,
    input wire sampled_bit,
    output reg strt_glitch
);
    wire strt_glitch_t;

    always @(posedge clk, negedge rst) begin
        if(!rst)
        strt_glitch<=0;
        else if (strt_chk_en)
        strt_glitch <= strt_glitch_t;
        else
        strt_glitch <= strt_glitch;
    end

    assign strt_glitch_t = (sampled_bit==0) ? 0 : 1 ; 
    
endmodule