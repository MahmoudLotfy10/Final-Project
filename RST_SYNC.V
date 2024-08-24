module RST_SYNC #(
    parameter NUM_STAGES=2
) (
    input wire clk,
    input wire rst,
    output wire sync_rst
);
    reg [NUM_STAGES-1 : 0] stages;
    integer i;

   always @(posedge clk , negedge rst) begin
    if(!rst) begin

        stages   <= 'b0;
        
    end

    else begin
        /*
        stages[NUM_STAGES-1]<=1;
        for (i =NUM_STAGES-2 ; i>=0; i=i-1 ) begin
          stages[i] <= stages[i+1];  
        end*/
        stages <= {1'b1,stages[NUM_STAGES-1:1]};
    end

   end 

    assign sync_rst = stages[0];

endmodule