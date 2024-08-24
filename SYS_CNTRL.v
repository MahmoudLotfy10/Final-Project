module SYS_CNTRL #(
    parameter alU_width  = 16 ,
    parameter data_width = 8,
    parameter ALU_FUN_WIDTH=4,
    parameter ADDR_SIZE=4
) (
    input wire CLK,
    input wire RST,
    input wire [alU_width-1:0]ALU_OUT,
    input wire OUT_VALID,
    input wire [data_width-1:0] RX_P_DATA,
    input wire RX_DATA_VALID,
    input wire [data_width-1:0] RDDATA, //reg file
    input wire RDDATA_VALID,            // reg file
    input wire fifo_full,

    output reg ALU_EN,
    output reg [ALU_FUN_WIDTH-1:0]ALU_FUN,
    output reg CLK_EN,
    output reg [ADDR_SIZE-1:0] Address,
    output reg WREN,
    output reg RDEN,
    output reg [data_width-1:0] WR_D, //regfile
    output reg [data_width-1:0] WR_DATA, //fifo
    output reg W_INC ,//fifo
    //output reg [data_width-1:0] TX_P_DATA,
    //output reg TX_DATA_VALID,
    output reg CLK_DIV_EN


);

localparam state_width=4;

    localparam [state_width-1:0]  ideal = 4'b0000 ,
                                  reg_file_write_frame_1 = 4'b0001,
                                  reg_file_write_frame_2 = 4'b0010,
                                  reg_file_read_frame_1  = 4'b0011,
                                  alu_operand_a = 4'b0100,
                                  alu_operand_b = 4'b0101,
                                  alu_func = 4'b0110,
                                  go_to_fifo_after_alu_least=4'b0111,
                                  go_to_fifo_after_alu_most=4'b1000,
                                  go_to_fifo_after_read_reg_file=4'b1001;
    

    localparam [data_width-1:0] write_to_regfile    =  8'b1010_1010 ,
                                read_from_regfile   =  8'b1011_1011,
                                alu_with_operand    =  8'b1100_1100,
                                alu_without_operand =  8'b1101_1101; 
        

reg [state_width-1:0]cur_state,next_state;
reg [ALU_FUN_WIDTH-1:0]ALU_FUN_reg;
reg [ADDR_SIZE-1:0] Address_reg;
reg [data_width-1:0] WR_DATA_reg; //fifo
//reg [data_width-1:0] TX_P_DATA_reg;
//reg TX_DATA_VALID_reg;
reg [data_width-1:0] WR_D_reg;
reg W_INC_reg;

reg ALU_EN_reg,
    CLK_EN_reg,
    WREN_reg,
    RDEN_reg;
always @(posedge CLK, negedge RST) begin
    if(!RST) begin
        cur_state  <= ideal;
        ALU_FUN <= 0;
        Address <= 4;
        WR_DATA <=0;
        WR_D<=0;
       // TX_P_DATA<=0;
        //TX_DATA_VALID<=0;
        ALU_EN<= 0;
        CLK_EN<= 0;
        WREN  <= 0;
        RDEN  <= 0;
        W_INC <=0;
    end
    else begin
        cur_state <= next_state ;
        ALU_FUN   <= ALU_FUN_reg;
        Address   <= Address_reg;
        WR_DATA    <= WR_DATA_reg;
       // TX_P_DATA <=TX_P_DATA_reg;
        //TX_DATA_VALID<=TX_DATA_VALID_reg;
        ALU_EN<= ALU_EN_reg;
        CLK_EN<= CLK_EN_reg;
        WREN  <= WREN_reg;
        RDEN  <= RDEN_reg;
        WR_D<=WR_D_reg;
        W_INC<=W_INC_reg;
    end
end




always @(*) begin

    next_state=ideal;
    ALU_FUN_reg=ALU_FUN;
    Address_reg=Address;
    WR_D_reg=WR_D;
    WR_DATA_reg=WR_DATA;
    //TX_P_DATA_reg=0;
    //TX_DATA_VALID_reg=0;
    ALU_EN_reg=0;
    CLK_EN_reg=0;
    WREN_reg=0;
    RDEN_reg=0;
    CLK_DIV_EN=1;
    W_INC_reg=0;

    case (cur_state)

       ideal : begin
        if(RX_DATA_VALID) begin

        case (RX_P_DATA)
           write_to_regfile : begin
            next_state = reg_file_write_frame_1;
           // WREN_reg=1;
           end
           read_from_regfile:begin
            next_state = reg_file_read_frame_1;
           // RDEN_reg=1;
           end
           alu_with_operand:begin
            next_state = alu_operand_a;
            ALU_EN_reg=0;
            CLK_EN_reg=1;

           end
           alu_without_operand: begin
            next_state = alu_func;
            ALU_EN_reg=0;
            CLK_EN_reg=1;
           end
            default: begin
                next_state=ideal;
            end
        endcase

       end
       
       else begin
        next_state = ideal;
       end

       end
       reg_file_write_frame_1: begin
        if(RX_DATA_VALID) begin
          next_state = reg_file_write_frame_2;
          //WREN_reg=1;  
          Address_reg = RX_P_DATA [data_width/2 -1 : 0];
        end
        else begin
            next_state=reg_file_write_frame_1;
            //WREN_reg=1;
        end
       end
       reg_file_write_frame_2:begin
        if(RX_DATA_VALID) begin
          next_state = ideal;
          WREN_reg=1;  
          WR_D_reg = RX_P_DATA;
          Address_reg=Address;
        end
        else begin
            next_state=reg_file_write_frame_2;
            WREN_reg=1;
            Address_reg=Address;
        end
       end

       reg_file_read_frame_1:begin
        if(RX_DATA_VALID) begin
          next_state = go_to_fifo_after_read_reg_file;
          RDEN_reg=1;   
          Address_reg = RX_P_DATA [data_width/2 -1 : 0];
        end
        else begin
            next_state=reg_file_read_frame_1;
            RDEN_reg=1;
            Address_reg=Address;
        end
       end

       go_to_fifo_after_read_reg_file:
       begin
        if(RDDATA_VALID && !fifo_full) begin
          next_state = ideal;
          WR_DATA_reg= RDDATA; 
          W_INC_reg=1;
          Address_reg=Address;
        end
        else begin
            next_state=go_to_fifo_after_read_reg_file;
            Address_reg=Address;
        end
       end

       alu_operand_a:begin
        if(RX_DATA_VALID) begin
          next_state = alu_operand_b;
          ALU_EN_reg=0;
          CLK_EN_reg=1;  
          WREN_reg=1;
          WR_D_reg = RX_P_DATA;
          Address_reg = 0;
        end
        else begin
            next_state=alu_operand_a;
            ALU_EN_reg=0;
            CLK_EN_reg=1;  
            WREN_reg=1;
            Address_reg=Address;
        end
       end

       alu_operand_b:begin
        if(RX_DATA_VALID) begin
          next_state = alu_func;
          ALU_EN_reg=0;
          CLK_EN_reg=1;  
          WREN_reg=1;
          WR_D_reg = RX_P_DATA;
          Address_reg = 1;
        end
        else begin
            next_state=alu_operand_b;
            ALU_EN_reg=0;
            CLK_EN_reg=1;  
            WREN_reg=1;
            Address_reg=Address;
        end
       end
       alu_func: begin
        if(RX_DATA_VALID) begin
          next_state = go_to_fifo_after_alu_least;
          ALU_EN_reg=0;
          CLK_EN_reg=1;  
          ALU_FUN_reg = RX_P_DATA[data_width/2 -1 : 0];
          Address_reg=Address;
        end
        else begin
            next_state=alu_func;
            ALU_EN_reg=0;
            CLK_EN_reg=1;  
            Address_reg=Address;
        end
       end
       go_to_fifo_after_alu_least: begin
        if(OUT_VALID && !fifo_full) begin
          next_state = go_to_fifo_after_alu_most;
          W_INC_reg=1; 
          WR_DATA_reg= ALU_OUT[(alU_width/2)-1:0]; 
          Address_reg=Address;

          ALU_EN_reg=1;
          CLK_EN_reg=1;
            
        end
        else begin
            next_state=go_to_fifo_after_alu_least;
            Address_reg=Address;

          ALU_EN_reg=1;
          CLK_EN_reg=1;
        end
       end
       go_to_fifo_after_alu_most:begin
        if(OUT_VALID && !fifo_full) begin
        
          next_state = ideal;
          W_INC_reg=1; 
          WR_DATA_reg= ALU_OUT[alU_width-1:(alU_width/2)]; 
          Address_reg=Address;

            ALU_EN_reg=0;
            CLK_EN_reg=1;
            
        end
        else begin
            next_state=go_to_fifo_after_alu_most;
            Address_reg=Address;

            ALU_EN_reg=0;
            CLK_EN_reg=1;
        end
       end
        default: begin
            next_state=ideal;
            ALU_FUN_reg=0;
            Address_reg=4;
            WR_D_reg=0;
            WR_DATA_reg=0;
            //TX_P_DATA_reg=0;
            //TX_DATA_VALID_reg=0;
            ALU_EN_reg=0;
            CLK_EN_reg=0;
            WREN_reg=0;
            RDEN_reg=0;
            CLK_DIV_EN=1;
            W_INC_reg=0;
        end
    endcase


end

endmodule