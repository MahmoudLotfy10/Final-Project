module DATA_SYNC #(
    parameter NUM_STAGES =3, 
    parameter BUS_WIDTH =8
) (
    input wire clk,
    input wire rst,
    input wire [BUS_WIDTH-1:0] unsync_bus,
    input wire bus_enable,
    output reg [BUS_WIDTH-1:0] sync_bus,
    output reg enable_pulse
);
    wire out_multi_flip_flop,pluse_generated_w;
    multi_flip_flop #(.num_of_stages(NUM_STAGES))multi_flip_flop_1
    (
        .clk(clk),
        .rst(rst),
        .bus_enable(bus_enable),
        .out(out_multi_flip_flop)

    );
    pulse_gen pulse_gen_1
    (
        .clk(clk),
        .rst(rst),
        .d(out_multi_flip_flop),
        .pluse_generated(pluse_generated_w)
    );

    wire [BUS_WIDTH-1:0] sync_bus_w;

    assign sync_bus_w = pluse_generated_w ? unsync_bus : sync_bus  ;

    always @(posedge clk , negedge rst) begin
        if(!rst) begin
            enable_pulse <= 0;
            sync_bus <= 0;
        end
        else begin
            enable_pulse <= pluse_generated_w;
            sync_bus <= sync_bus_w ;
        end
    end

endmodule