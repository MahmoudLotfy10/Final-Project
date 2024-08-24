`timescale 1ns/1ps
module SYSTEM_TOP_TB #(
     //uart_top
        parameter data_width=8,prescale_width=6,no_of_bits_in_frame =11,
    //data_sync
        parameter NUM_STAGES_data_sync =3,
    //sys control
        parameter alU_width  = 16 ,
        parameter ALU_FUN_WIDTH=4,
        parameter ADDR_SIZE=4,
    //reg file
        parameter DEPTH_regfile = 16,ADDR_regfile = 4,
    //fifo
        parameter P_WIDTH    = 4  ,
        parameter debth_fifo = 8  ,
        parameter NUM_STAGES_fifo = 2 ,
    //clk_div
        parameter integer_width = 8,
    //rst_sync
        parameter NUM_STAGES_rst_sync=2,
    //mux of prescale
        parameter out_width=8

) ();
    reg   REF_CLK ;
    reg   UART_CLK;
    reg   RST;
    reg   RX_IN;
    wire  TX_OUT;
    wire  stp_err;
    wire  par_err ;

SYSTEM_TOP #(
    .data_width(data_width),
    .prescale_width(prescale_width),
    .no_of_bits_in_frame(no_of_bits_in_frame),
    .NUM_STAGES_data_sync(NUM_STAGES_data_sync),
    .alU_width(alU_width),
    .ALU_FUN_WIDTH(ALU_FUN_WIDTH),
    .ADDR_SIZE(ADDR_SIZE),
    .DEPTH_regfile(DEPTH_regfile),
    .ADDR_regfile(ADDR_regfile),
    .P_WIDTH(P_WIDTH),
    .debth_fifo(debth_fifo),
    .NUM_STAGES_fifo(NUM_STAGES_fifo),
    .integer_width(integer_width),
    .NUM_STAGES_rst_sync(NUM_STAGES_rst_sync),
    .out_width(out_width)
    
) uut
(
    .REF_CLK(REF_CLK),
    .UART_CLK(UART_CLK),
    .RST(RST),
    .RX_IN(RX_IN),
    .TX_OUT(TX_OUT),
    .stp_err(stp_err),
    .par_err(par_err)
    

);

localparam ref_clk_period=20;
always #(ref_clk_period/2) REF_CLK=~REF_CLK;

localparam uart_clk_period=271;
always #(uart_clk_period/2) UART_CLK=~UART_CLK;

initial begin
    REF_CLK=0;
    RST=0;
    #(ref_clk_period/2)
    RST=1;
    repeat(3) @(negedge REF_CLK);

end
//odd parity
initial begin
    UART_CLK=0;
    RST=0;
    #(uart_clk_period/2)
    RST=1;
    repeat(3) @(negedge UART_CLK);

    command();

   // @(posedge uut.UART.parity_type);
    command_with_even_parity();
   
    repeat(12800) @(negedge UART_CLK);
    $stop;

end

initial begin
    #(uart_clk_period/2);
    repeat(3) @(negedge UART_CLK);
$display("***********************************************************************************************");
$display("***********************************************************************************************");
$display("********* UART Configuration is Prescale = %d , Parity Enable = %d ,, Parity Type =%d  **********",uut.RegFile0.REG2[7:2],uut.RegFile0.REG2[0],uut.RegFile0.REG2[1]);
$display("***********************************************************************************************");
$display("***********************************************************************************************");

TEST();
$display("************************** NOW WILL change configuration of UART*****************************************");

 
repeat(3) @(negedge UART_CLK);
$display("***********************************************************************************************");
$display("***********************************************************************************************");
$display("********* UART Configuration is Prescale = %d , Parity Enable = %d ,, Parity Type =%d  **********",uut.RegFile0.REG2[7:2],uut.RegFile0.REG2[0],uut.RegFile0.REG2[1]);
$display("***********************************************************************************************");
$display("***********************************************************************************************");
TEST();



    

end

task TEST;
begin
  $display("************************** NOW WILL TEST Command aa write Command *****************************************");
    test_write();
$display("************************** NOW WILL TEST Command bb read Command *****************************************");

    test_read();
$display("************************** NOW WILL TEST Command cc ALU_WITH_OPERAND Command *****************************************");

    test_alu(8'hab,8'hab,(8'hab+8'hab),"ALU_WITH_OPERAND ADD operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab-8'hab),"ALU_WITH_OPERAND sub operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab*8'hab),"ALU_WITH_OPERAND mul operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab/8'hab),"ALU_WITH_OPERAND DIV operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab&8'hab),"ALU_WITH_OPERAND AND operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab|8'hab),"ALU_WITH_OPERAND OR operation then read output from interface",1);
    test_alu(8'hab,8'hab,~(8'hab & 8'hab),"ALU_WITH_OPERAND NAND operation then read output from interface",1);
    test_alu(8'hab,8'hab,~(8'hab | 8'hab),"ALU_WITH_OPERAND NOR operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab^8'hab),"ALU_WITH_OPERAND XOR operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab ~^ 8'hab),"ALU_WITH_OPERAND XNOR operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab==8'hab),"ALU_WITH_OPERAND IF(A==B) operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab>8'hab),"ALU_WITH_OPERAND IF(A>B) operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab<8'hab),"ALU_WITH_OPERAND IF(A<B) operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab>>1),"ALU_WITH_OPERAND Shift A Right operation then read output from interface",1);
    test_alu(8'hab,8'hab,(8'hab<<1),"ALU_WITH_OPERAND Shift A left operation then read output from interface",1);

$display("************************** NOW WILL TEST Command dd ALU_WITH_OUT_OPERAND(will use the values in REG0 , REG1) Command *****************************************");

    test_alu_witout_operand(8'hab,8'hab,(8'hab+8'hab),"ALU_WITH_OUT_OPERAND ADD operation then read output from interface",1,14);
    test_alu_witout_operand(8'hab,8'hab,(8'hab-8'hab),"ALU_WITH_OUT_OPERAND sub operation then read output from interface",3,14);
    test_alu_witout_operand(8'hab,8'hab,(8'hab*8'hab),"ALU_WITH_OUT_OPERAND mul operation then read output from interface",3,14);
    test_alu_witout_operand(8'hab,8'hab,(8'hab/8'hab),"ALU_WITH_OUT_OPERAND DIV operation then read output from interface",3,14);
    test_alu_witout_operand(8'hab,8'hab,(8'hab&8'hab),"ALU_WITH_OUT_OPERAND AND operation then read output from interface",5,14);
    test_alu_witout_operand(8'hab,8'hab,(8'hab|8'hab),"ALU_WITH_OUT_OPERAND OR operation then read output from interface",7,14);
    test_alu_witout_operand(8'hab,8'hab,~(8'hab & 8'hab),"ALU_WITH_OUT_OPERAND NAND operation then read output from interface",9,14);
   
end
endtask
////////////////////////////////////////////////////
task take_one_frame;

input reg [no_of_bits_in_frame-1:0] task_frame;
integer i;
integer j;
begin

        for(i=no_of_bits_in_frame-1; i>=0; i=i-1)begin
         @(negedge (uut.UART.CLK_TX));
         RX_IN= task_frame[i];
        
    end 
   
end
endtask
////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////
task test_write;

begin
    $display("--------------write to reg file--------------------");
    wait(uut.RegFile0.WrEn);
     @(negedge uut.RegFile0.WrEn);
    @(negedge uut.RegFile0.CLK);
    if((uut.RegFile0.WrData)==8'b1010_1010) begin
        $display("The WrData = %b as expected",uut.RegFile0.WrData);
        $display("--------------this test case succeded--------------------");
    end
    else begin
        $display("--------------this test case failed--------------------");

    end
    $display("-------------------------------------------------------------------------------------------");
end

endtask
///////////////////////////////////////////////////////////////////////////////

task test_read;

begin
    $display("--------------read from reg file using interface--------------------");
    wait(uut.UART.Data_Valid);
    if((uut.UART.P_DATA)==8'b1010_1010) begin
        $display("The RdData  = %b as expected",uut.UART.P_DATA);
        $display("--------------this test case succeded--------------------");
    end
    else begin
        $display("--------------this test case failed--------------------");

    end
        $display("-------------------------------------------------------------------------------------------");

end
endtask
////////////////////////////////////////////////////////////////////////////////////////
task test_alu;
input [data_width-1:0]opA,OpB;
input [alU_width-1:0] out;
input [1000:0] string;
input [20:0]r;
begin
    $display("--------------%0s--------------------",string);

 
   repeat(r)@(posedge uut.UART.Data_Valid);
 /*  @(negedge uut.RegFile0.WrEn);
   @(negedge uut.UART.CLK_TX);*/
    if((uut.ALU0.A)==opA && (uut.ALU0.B)==OpB &&(uut.UART.P_DATA)==out[alU_width/2 -1:0]) begin
        $display("The opearnd A = %h The opearnd A = %h and as expected and the least bits P_DATA= %h",uut.ALU0.A, uut.ALU0.B,uut.UART.P_DATA);
        repeat (7) @(negedge uut.UART.CLK_TX);
        if((uut.UART.P_DATA)==out[alU_width-1:alU_width/2]) begin
        $display("and as expected and the most bits P_DATA= %h",uut.UART.P_DATA);
        $display("--------------this test case succeded--------------------");

        end
         else begin
        $display("The opearnd A = %d The opearnd A = %d and as expected and the least bits P_DATA=",uut.ALU0.A , uut.ALU0.B,uut.UART.P_DATA);

        $display("--------------this test case failed--------------------");

    end
    end
    else begin
        $display("The opearnd A = %d The opearnd A = %d and as expected and the least bits P_DATA=",uut.RegFile0.REG0 , uut.RegFile0.REG1,uut.UART.P_DATA);

        $display("--------------this test case failed--------------------");

    end
        $display("-------------------------------------------------------------------------------------------");

end
endtask






task test_alu_witout_operand;
input [data_width-1:0]opA,OpB;
input [alU_width-1:0] out;
input [1000:0] string;
input [20:0]r;
input [20:0]r1;
begin
    $display("--------------%0s--------------------",string);

 
 //repeat(1)@(negedge uut.DATA_SYNC0.bus_enable);
 @(negedge uut.ALU0.OUT_VALID);
  repeat(r)@(negedge uut.UART.CLK_TX);
 /*  @(negedge uut.RegFile0.WrEn);*/
   @(negedge uut.UART.CLK_TX);
    if((uut.ALU0.A)==opA && (uut.ALU0.B)==OpB &&(uut.UART.P_DATA)==out[alU_width/2 -1:0]) begin
        $display("The opearnd A = %h The opearnd A = %h and as expected and the least bits P_DATA= %h",uut.ALU0.A, uut.ALU0.B,uut.UART.P_DATA);
        repeat (r1) @(negedge uut.UART.CLK_TX);
        if((uut.UART.P_DATA)==out[alU_width-1:alU_width/2]) begin
        $display("and as expected and the most bits P_DATA= %h",uut.UART.P_DATA);
        $display("--------------this test case succeded--------------------");

        end
         else begin
        $display("The opearnd A = %d The opearnd A = %d and as expected and the least bits P_DATA=",uut.ALU0.A , uut.ALU0.B,uut.UART.P_DATA);

        $display("--------------this test case failed--------------------");

    end
    end
    else begin
        $display("The opearnd A = %h The opearnd A = %h and as expected and the least bits P_DATA=%h",uut.RegFile0.REG0 , uut.RegFile0.REG1,uut.UART.P_DATA);

        $display("--------------this test case failed--------------------");

    end
        $display("-------------------------------------------------------------------------------------------");

end
endtask
////////////////////////////////////////////////////////////////////////////////////////////


task command;
begin
 //write to reg
   take_one_frame(11'b0_1010_1010_11);
    
    take_one_frame(11'b0_1010_1010_11);
    
    take_one_frame(11'b0_1010_1010_11);
  
//read from reg
    
    take_one_frame(11'b0_1011_1011_11);
    
    take_one_frame(11'b0_1010_1010_11);

//alu with operand add
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0000_11);
//alu with operand sub
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0001_01);
//alu with operand mul
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0010_01);
//alu with operand div
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0011_11);
//alu with operand and
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0100_01);

//alu with operand or
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0101_11);
//alu with operand nand
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0110_11);

//alu with operand nor
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_0111_01);
//alu with operand Xor
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1000_01);

//alu with operand Xnor
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1001_11);

//alu with operand equal
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1010_11);

//alu with operand greater than
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);

//alu with operand less than
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1100_11);

//alu with operand shift a right
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1101_01);

//alu with operand shift a left
    
    take_one_frame(11'b0_1100_1100_11);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1011_01);
    take_one_frame(11'b0_1010_1110_01);



    ///////////////////////////////////////////////////////



//alu with out operand add
    
    take_one_frame(11'b0_1101_1101_11);
    take_one_frame(11'b0_1010_0000_11);
//alu with out operand sub
    
    take_one_frame(11'b0_1101_1101_11);
    take_one_frame(11'b0_1010_0001_01);
//alu with out operand mul
    take_one_frame(11'b0_1101_1101_11);
    take_one_frame(11'b0_1010_0010_01);
//alu with out operand div
    
    take_one_frame(11'b0_1101_1101_11);
    take_one_frame(11'b0_1010_0011_11);
//alu with out operand and
    
    take_one_frame(11'b0_1101_1101_11);
    take_one_frame(11'b0_1010_0100_01);

//alu with out operand or
    
    take_one_frame(11'b0_1101_1101_11);
    take_one_frame(11'b0_1010_0101_11);
//alu with out operand nand
    
    take_one_frame(11'b0_1101_1101_11);
    take_one_frame(11'b0_1010_0110_11);

////////////////////////////////////////////////
//change configuration
 #6400
 uut.RegFile0.regArr[2][7:0]=8'b01000011;





   
  //  repeat(10) @(negedge UART_CLK);
   //@(negedge (uut.UART.CLK_TX))
    

    

end
endtask

task command_with_even_parity;
begin
 //write to reg
   take_one_frame(11'b0_1010_1010_01);
    
    take_one_frame(11'b0_1010_1010_01);
    
    take_one_frame(11'b0_1010_1010_01);
  
//read from reg
    
    take_one_frame(11'b0_1011_1011_01);
    
    take_one_frame(11'b0_1010_1010_01);

//alu with operand add
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0000_01);
//alu with operand sub
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0001_11);
//alu with operand mul
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0010_11);
//alu with operand div
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0011_01);
//alu with operand and
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0100_11);

//alu with operand or
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0101_01);
//alu with operand nand
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0110_01);

//alu with operand nor
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_0111_11);
//alu with operand Xor
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1000_11);

//alu with operand Xnor
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1001_01);

//alu with operand equal
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1010_01);

//alu with operand greater than
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);

//alu with operand less than
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1100_01);

//alu with operand shift a right
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1101_11);

//alu with operand shift a left
    
    take_one_frame(11'b0_1100_1100_01);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1011_11);
    take_one_frame(11'b0_1010_1110_11);



    ///////////////////////////////////////////////////////



//alu with out operand add
    
    take_one_frame(11'b0_1101_1101_01);
    take_one_frame(11'b0_1010_0000_01);
//alu with out operand sub
    
    take_one_frame(11'b0_1101_1101_01);
    take_one_frame(11'b0_1010_0001_11);
//alu with out operand mul
    take_one_frame(11'b0_1101_1101_01);
    take_one_frame(11'b0_1010_0010_11);
//alu with out operand div
    
    take_one_frame(11'b0_1101_1101_01);
    take_one_frame(11'b0_1010_0011_01);
//alu with out operand and
    
    take_one_frame(11'b0_1101_1101_01);
    take_one_frame(11'b0_1010_0100_11);

//alu with out operand or
    
    take_one_frame(11'b0_1101_1101_01);
    take_one_frame(11'b0_1010_0101_01);
//alu with out operand nand
    
    take_one_frame(11'b0_1101_1101_01);
    take_one_frame(11'b0_1010_0110_01);

////////////////////////////////////////////////
    

end
endtask

endmodule