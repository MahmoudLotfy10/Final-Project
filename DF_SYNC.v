module DF_SYNC #(parameter P_WIDTH=4,NUM_STAGES=2)(
    input                  clk,
    input                  rst,
    input      [P_WIDTH-1:0] in,
    output reg [P_WIDTH-1:0] out
);
    reg [NUM_STAGES-1:0]stages [P_WIDTH-1:0];
    integer i;
    always @(posedge clk , negedge rst) begin
        if(!rst) begin
            for(i=P_WIDTH-1; i>=0; i=i-1)
            stages[i] <=0;
        end
        else begin
            for(i=P_WIDTH-1; i>=0; i=i-1)
            stages[i] <= {in[i],stages[i][NUM_STAGES-1:1]};
        end
    end

    always @(*) begin
        for(i=P_WIDTH-1; i>=0; i=i-1)
        out[i]= stages[i][0];
    end
endmodule