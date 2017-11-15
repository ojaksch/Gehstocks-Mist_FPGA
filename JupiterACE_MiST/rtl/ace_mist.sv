`timescale 1ns / 1ps
`default_nettype none

module ace_mist(
	input         CLOCK_27,
   output  [5:0] VGA_R,
   output  [5:0] VGA_G,
   output  [5:0] VGA_B,
   output        VGA_HS,
   output        VGA_VS,	 
   output        LED,
   output        AUDIO_L,
   output        AUDIO_R,
   output        UART_TX,//uses for Tape Record
   input         UART_RX,//uses for Tape Play	
   input         SPI_SCK,
   output        SPI_DO,
   input         SPI_DI,
   input         SPI_SS2,
   input         SPI_SS3,
	input         SPI_SS4,
   input         CONF_DATA0,
   output [12:0] SDRAM_A,
   inout  [15:0] SDRAM_DQ,
   output        SDRAM_DQML,
   output        SDRAM_DQMH,
   output        SDRAM_nWE,
   output        SDRAM_nCAS,
   output        SDRAM_nRAS,
   output        SDRAM_nCS,
   output  [1:0] SDRAM_BA,
   output        SDRAM_CLK,
   output        SDRAM_CKE
    );
	 
	 localparam CONF_STR = {
		  "Jupiter ACE;;",
		  "O23,Scandoubler Fx,None,CRT 25%,CRT 50%;",
		  "T5,Reset;",
		  "V,v0.2;"
};
//		Disable SDRAM
assign SDRAM_nCS = 1'b0;

//   	MIST ARM I/O
assign LED = 1'b1;

wire        scandoubler_disable;
wire        ypbpr;
wire        ps2_kbd_clk, ps2_kbd_data;

wire [31:0] status;
wire  [1:0] buttons;
wire  [1:0] switches;


wire        ioctl_wr;
wire [24:0] ioctl_addr;
//wire  [7:0] ioctl_data;
wire        ioctl_download;
wire        ioctl_erasing;
wire  [7:0] ioctl_index;

wire [31:0] sd_lba = "0";
wire        sd_rd = "00000000";
wire        sd_wr = "00000000";
wire        sd_ack;
wire  [8:0] sd_buff_addr;
wire  [7:0] sd_buff_dout;
wire  [7:0] sd_buff_din = "0";
wire        sd_buff_wr;
wire        img_mounted;
wire [31:0] img_size;


mist_io #(.STRLEN(($size(CONF_STR)>>3))) mist_io
(
	.*,
	.conf_str(CONF_STR),
	.sd_conf(0),
	.sd_sdhc(1),
	.joystick_0(),
	.joystick_1(),
	.joystick_analog_0(),
	.joystick_analog_1(),
	.ioctl_force_erase(),
	.ioctl_dout(),
	.sd_ack_conf(),
	.switches(),
	.ps2_mouse_clk(),
	.ps2_mouse_data()
);

//		CLOCKS
   wire 				clk_sys; // 26.666666MHz
   wire 				clk_65;  // 6.5MHz main frequency Jupiter ACE
   wire 				clk_cpu; // CPU CLK
	wire 				ps2_clk;
	wire 				tape_clock;	
	wire 				locked;
	wire 				reset = buttons[1] | status[0] | status[5];
	
	  pll27 pll27_inst (
		.areset(reset),
		.inclk0(CLOCK_27),
		.c0(clk_sys),//26.0Mhz
		.c1(clk_65),//6.5Mhz
		.c2(clk_cpu),//3.25Mhz
		.locked(locked)
		);
// 	Power-on RESET (8 clocks)
    reg [7:0] poweron_reset = 8'h00;
	 reg resetn;
    always @(posedge clk_65) begin
        poweron_reset <= {poweron_reset[6:0],1'b1};
		  resetn <= (kbd_reset & poweron_reset[7]) | reset;
    end
 
wire audio, audiodac;
wire TapeIn;
wire TapeOut;

    jupiter_ace the_core (
        .clk_65(clk_65),
        .clk_cpu(clk_cpu),
        .reset(resetn),
        .filas(kbd_rows),
        .columnas(kbd_columns),
        .video(video),
        .hsync(HSync),
	     .vsync(VSync),
        .ear(UART_RX),//Play
        .mic(UART_TX),//Record
        .spk(audio)
	);
	
    sigma_delta_dac dac (	
		.DACout(audiodac),
		.DACin(audio & audio & audio & audio & audio & audio & audio),
		.CLK(clk_65),
		.RESET(resetn)
	);
		
assign AUDIO_R = audiodac;
assign AUDIO_L = audiodac;

wire 				kbd_reset;
wire 				kbd_mreset;
wire 				[7:0] kbd_rows;
wire 				[4:0] kbd_columns;
	
    keyboard the_keyboard (
        .clk(clk_65),
        .clkps2(ps2_kbd_clk),
        .dataps2(ps2_kbd_data),
        .rows(kbd_rows),
        .columns(kbd_columns),
        .kbd_reset(kbd_reset),
        .kbd_nmi(),
        .kbd_mreset(kbd_mreset)        
    );
	 
wire video;
wire HSync, VSync;
wire [2:0] R = {video,video,1'b0};
wire [2:0] G = {video,video,1'b0};
wire [2:0] B = {video,video,1'b0};	 

video_mixer #(.LINE_LENGTH(348), .HALF_DEPTH(1)) video_mixer
(
	.*,
	.clk_sys(clk_sys),
	.ce_pix(clk_65),
	.ce_pix_actual(clk_65),
	.scanlines(scandoubler_disable ? 2'b00 : {status[3:2] == 2, status[3:2] == 1}),
	.hq2x(),//not needed
	.ypbpr(ypbpr),
	.ypbpr_full(1),
	.line_start(0),
	.mono(0)
);

endmodule
