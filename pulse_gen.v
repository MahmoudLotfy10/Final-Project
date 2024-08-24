module pulse_gen (
    input clk,
    input rst,
    input d,
    output pluse_generated

);
  reg    rcv_flop  , 
         pls_flop  ;

    always @(posedge clk, negedge rst) begin
        if(!rst) begin
            rcv_flop <= 1'b0 ;
            pls_flop <= 1'b0 ;
        end
        else begin
           rcv_flop <= d;   
           pls_flop <= rcv_flop;  
        end
    end

    assign pluse_generated = rcv_flop && !pls_flop ;

endmodule