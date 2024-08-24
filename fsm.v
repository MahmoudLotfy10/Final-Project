module fsm #(parameter prescale_width=6) (

    input wire clk,
    input wire rst,
    input wire RX_IN,
    input wire PAR_EN,
    input wire [3:0] bit_cnt,
    input wire [prescale_width-1:0] prescale,
    input wire [prescale_width-1:0] edge_cnt,
    input wire par_err,
    input wire strt_glitch,
    input wire stp_err,
    output reg data_samp_en,
    output reg par_chk_en,
    output reg strt_chk_en,
    output reg stp_chk_en,
    output reg edge_bit_counter_enable,
    output reg deser_en,
    output reg data_valid
   
);
    
    localparam [2:0] idle   = 3'b000 ,
                     start  = 3'b001 ,
                     data   = 3'b010 ,
                     parity = 3'b011 ,
                     stop   = 3'b100 ,
                     check  = 3'b101 ;
    
    
    reg  [2:0] cur_state , next_state;
    always @(posedge clk , negedge rst) 
    begin
      
      if(!rst) begin
      cur_state  <= idle ;
      data_valid <= 0;
      end
      else begin
      cur_state  <= next_state ;
      data_valid <= data_valid ;
      end
    end

    always @(*) begin
        next_state=cur_state;
        data_samp_en = 0 ;
        par_chk_en   = 0 ;
        strt_chk_en  = 0 ;
        stp_chk_en   = 0 ;
        edge_bit_counter_enable = 0 ;
        deser_en     = 0 ;
        data_valid = 0 ;

        case (cur_state)
            idle:   begin
                if(!RX_IN) begin
                    next_state=start;
                    strt_chk_en=1;
                    data_samp_en=1;
                    edge_bit_counter_enable=1;

                end
                else begin
                    next_state=idle;
                    data_samp_en=1;
                    edge_bit_counter_enable=1;
                end
            end
            start:begin
                   strt_chk_en=1;
                    data_samp_en=1;
                    edge_bit_counter_enable=1;
                 if( (bit_cnt==1 && edge_cnt==prescale-1)) begin
                    if(strt_glitch)
                    next_state=idle;
                    else begin
                    next_state=data;
                    data_samp_en=1;
                    edge_bit_counter_enable=1;
                    deser_en=1;

                    end
                end
               
                else begin
                    next_state=cur_state;
                    data_samp_en=1;
                    edge_bit_counter_enable=1;
                end
            end
            data:begin
                    data_samp_en=1;
                    edge_bit_counter_enable=1;
                    deser_en=1;
                    next_state=data;
                 if (bit_cnt==9 && ( edge_cnt==prescale-1)) begin
                    if(PAR_EN)begin
                        next_state=parity;

                    end
                    else begin
                        next_state=stop;
                    end
                end
                else begin
                    next_state=cur_state;
                end
            end
            parity:begin
                par_chk_en=1;
                data_samp_en=1;
                edge_bit_counter_enable=1;
                if (bit_cnt==10 && ( edge_cnt==prescale-1)) begin
                    next_state = stop;
                end
                else begin
                    next_state = cur_state;
                end
            end
            stop:begin
                data_samp_en=1;
                edge_bit_counter_enable=1;
                stp_chk_en=1;
                if(PAR_EN)begin
                 if (bit_cnt==11 && ( edge_cnt==prescale-1)) begin
                    next_state=check;
                 end
                 else begin
                    next_state=cur_state;
                 end
                end
                else begin
                if (bit_cnt==10 && ( edge_cnt==prescale-1)) begin
                    next_state=check;
                end
                else begin
                    next_state=cur_state;
                 end
                end
            end
            check:begin
                data_samp_en=1;
                edge_bit_counter_enable=1;
                stp_chk_en=1;
                if(par_err | stp_err) begin
                data_valid=0;
                next_state=idle;
                end
                else begin
                data_valid=1;

                if(!RX_IN)begin
                next_state=start;
                strt_chk_en=1;
                data_samp_en=1;
                edge_bit_counter_enable=1;
                end
                else begin
                    data_samp_en=1;
                    edge_bit_counter_enable=1;
                    next_state=idle;
                end
                end
            end
            default: begin
                next_state   = idle;
                data_samp_en = 0 ;
                par_chk_en   = 0 ;
                strt_chk_en  = 0 ;
                stp_chk_en   = 0 ;
                edge_bit_counter_enable = 0 ;
                deser_en     = 0 ;
                data_valid   = 0 ;
            end
        endcase
    end
endmodule