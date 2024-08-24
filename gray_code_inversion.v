module gray_code_inversion #(
    parameter width=8
) (
    input wire [width-1:0] binary,
    output wire [width-1:0] gray
);
    reg [width-1:0] gray_temp;
    integer i;

  always @(*) begin
    gray_temp[width-1] = binary [width-1];

    for(i=width-2; i>=0; i=i-1)
    begin
        gray_temp[i] = binary [i] ^ binary [i+1];
    end
  end
  
    assign gray = gray_temp;

endmodule