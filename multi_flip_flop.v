module multi_flip_flop #(parameter num_of_stages =3 )(
    input clk,
    input rst,
    input bus_enable,
    output out
);
   reg [num_of_stages-1:0] stages;

   always @(posedge clk , negedge rst) begin
    if(!rst) begin
        stages <= 0;
    end
    else begin
        stages <= {bus_enable , stages[num_of_stages-1:1]};
    end
   end 

   assign out = stages[0];
endmodule