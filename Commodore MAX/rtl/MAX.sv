module MAX(
	input				CLOCK_27,
	output	[5:0]	VGA_R,
	output	[5:0]	VGA_G,
	output	[5:0]	VGA_B,
	output			VGA_HS,
	output			VGA_VS
	);
	
wire clk_cpu;	
wire reset;
wire locked;

wire [15:0]CPU_ADDR;	
wire BA;
wire nRW;
wire nRAM;
wire nEXTRAM;
wire nVIC;
wire nSID;
wire nCIA;
wire nROML;
wire nROMH;
wire nCOLRAM;
wire nRW_PLA;
wire nIRQ;
wire nNMI;
wire AEC;


wire [3:0]COL_DATA;
wire [3:0]COL_DI;
wire [3:0]COL_DO;

wire [7:0]CPU_DATA;
wire [7:0]CPU_DI;
wire [7:0]CPU_DO;

always @(clk_cpu) begin
	CPU_DATA = nRW?CPU_DO:CPU_DI;
	COL_DATA = nRW?COL_DO:COL_DI;
end

pll pll(
	.inclk0(CLOCK_27),
	.areset(reset),
	.c0(clk_cpu),
	.locked(locked)
);	
	
//CPU
T65 U5(
	.Mode(2'b0),
	.Res_n(reset),
	.Enable(1),
	.Clk(clk_cpu),
	.Rdy(BA),
	.Abort_n(1),
	.IRQ_n(nIRQ),
	.NMI_n(nNMI),
	.SO_n(1),
	.R_W_n(nRW),
	.Sync(),
	.EF(),
	.MF(),
	.XF(),
	.ML_n(),
	.VP_n(),
	.VDA(),
	.VPA(),
	.A(CPU_ADDR),
	.DI(CPU_DO),
	.DO(CPU_DI)
	);

//PLA	
MOS6703 U8(
	.A(CPU_ADDR),
	.D({COL_DATA,CPU_DATA}),
	.CLK(clk_cpu),
	.BA(BA),
	.RW_IN(nRW),

	.RAM(nRAM), //invert
	.EXRAM(nEXTRAM), //invert
	.VIC(nVIC),  //invert
	.SID(nSID),  //invert
	.CIA(nCIA),//CIA_PLA  //invert
	.COLRAM(nCOLRAM),  //invert
	.ROML(nROML),  //invert
	.ROMH(nROMH), //invert
	.BUF(),//to the 4066 COLOR Ram DATA //invert
	.RW_OUT(nRW_PLA)  //invert
);	

//COLRAM
COLRAM U11(
	.address(CPU_ADDR[9:0]),
	.clock(clk_cpu),
	.data(COL_DO),
	.rden(nCOLRAM),
	.wren(nRW_PLA),
	.q(COL_DI)
);

//MAINRAM
MAINRAM U6(
	.address(CPU_ADDR[10:0]),
	.clock(clk_cpu),
	.data(CPU_DO),
	.rden(nRAM),
	.wren(nRW_PLA),
	.q(CPU_DI)
);	

video_vicii_656x U4(
	//.registeredAddress : boolean;
	//.emulateRefresh : boolean := false;
	//.emulateLightpen : boolean := false;
	//.emulateGraphics : boolean := true
	//);
	.clk(clk_cpu),
	.phi(),// phi = 0 is VIC cycle-- phi = 1 is CPU cycle (only used by VIC when BA is low)
	.enaData(),
	.enaPixel(),

	.baSync(),
	.ba(BA),

	.mode6569(0),// PAL 63 cycles and 312 lines
	.mode6567old(0),// old NTSC 64 cycles and 262 line
	.mode6567R8(1),// new NTSC 65 cycles and 263 line
	.mode6572(0),// PAL-N 65 cycles and 312 lines

	.reset(reset),
	.cs(nVIC),
	.we(nRW_PLA),
	.rd(),
	.lp_n(),

	.aRegisters(),
	.diRegisters(),

	.datai(CPU_DO),
	.diColor(COL_DO),
	.datao(CPU_DI),

	.vicAddr(),
	.irq_n(),
	.hSync(),
	.vSync(),
	.colorIndex(),
	.debugX(),
	.debugY(),
	.vicRefresh(),
	.addrValid()
);	
	


endmodule 