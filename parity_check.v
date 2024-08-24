module parity_check (
    input wire clk,rst,
    input wire sampled_bit,
    input wire par_chk_en ,
    input wire par_typ    ,
    input wire [7:0] p_data,
    output reg par_err
);
   wire par_err_t;
   wire parity ;
   
  always @(posedge clk , negedge rst) begin
    if (!rst)
    par_err <= 0;
    else if(par_chk_en)
    par_err <= par_err_t;
    else
    par_err <= par_err;
  end  

 assign parity = par_typ ? (^p_data) : (~^p_data);
 assign par_err_t =(sampled_bit==parity) ? 0 : 1; 
  
endmodule