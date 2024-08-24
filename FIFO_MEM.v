module FIFO_MEM #(
    parameter BUS_WIDTH = 16  ,
    parameter debth     = 8 ,
    parameter P_WIDTH   = 4
) (
    input wclk,
    input wclk_en,
    input wrst,
    input  [P_WIDTH-2:0]  waddr,
    input  [P_WIDTH-2:0]  raddr,
    input  [BUS_WIDTH-1:0] wdata,
    output [BUS_WIDTH-1:0] rdata
);
    reg [BUS_WIDTH-1:0] mem [debth-1:0];
    integer i;
    always @(posedge wclk ,negedge wrst) begin

        if(!wrst) begin

            for (i =debth-1 ; i>=0; i=i-1) begin
                mem[i] <=0;
            end

        end
        else if (wclk_en)
        mem[waddr] <= wdata;
        else
        mem[waddr] <= mem[waddr] ;
        
    end

    assign rdata = mem[raddr];

endmodule