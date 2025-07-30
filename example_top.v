`timescale 1ns/1ps

//	Update 24-03-16
//	1. Porting to 60F100 Dev Board. 
//	2. Introduced Skeleton Project. 

module example_top 
(
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	PLL & Clock Gen. Cascading: HDMI_PLL ----> DSI_PLL | HBRAM_PLL. 
	
	//	HBRAM Clock 
	output 			hbramClk_pll_rstn_o,	
	input 			hbramClk,			//	247.5MHz
	input 			hbramClk90,			//	247.5MHz
	input 			hbramClk_Cal,		//	247.5MHz
	input 			hbramClk_pll_lock,	
	
	//	HBRAM Clock PS
	output 	[2:0] 	hbramClk_shift,		
	output 			hbramClk_shift_ena,	
	output 	[4:0] 	hbramClk_shift_sel,	
	
	
	//	HDMI Clock (Using 1920*1080@60Hz)
	output 			hdmi_pll_rstn_o, 		
	input 			hdmi_pixel_10x,		//	742.5MHz Pixel Serial Clock 
	input 			hdmi_pixel,			//	148.5MHz Pixel Input 
	input 			sensor_xclk_i,		//	27MHz
	input 			sys_clk_i,			//	123.75MHz System Clock Input
	input 			hdmi_pll_lock, 		
	
	
	//	DSI TX / CSI TX Clock 
	output 			dsi_pll_rstn_o, 		
	input 			dsi_serclk_i,		//	750.2344MHz (45) DSI Serial Clock (D)
	input 			dsi_txcclk_i,		//	750.2344MHz (135) DSI Serial Clock (C)
	input 			dsi_byteclk_i, 		//	187.5586MHz DSI Byte Clock
	input 			dsi_fb_i, 			//	30.9375MHz DSI Reference Clock
	input 			dsi_pll_lock, 		
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	UART & Peripherals
	input 			uart_rx_i,			//	Use 460800-8-N-1
	output 			uart_tx_o,
	
	output 			led_o, 			//	Core LED Output (Invert)
	
	//	Config SPI 
	output 			spi_cs_o,			//	SPI_SSN | LED2 (Non-Inv) 
	output 			spi_cs_oe,
	
	output 			spi_sck_o,			//	SPI_SCK | CSI2_SCL
	output 			spi_sck_oe,
	
	input 			spi_mosi_d0_i,		//	MOSI_D0 | CSI_SCL
	output 			spi_mosi_d0_o,		
	output 			spi_mosi_d0_oe,
	
	input 			spi_miso_d1_i,		//	MISO_D1 | CSI_SDA 
	output 			spi_miso_d1_o,
	output 			spi_miso_d1_oe,
	
	input 			spi_wpn_d2_i,
	output 			spi_wpn_d2_o,
	output 			spi_wpn_d2_oe,
	
	input 			spi_holdn_d3_i,
	output 			spi_holdn_d3_o,
	output 			spi_holdn_d3_oe,
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	MIPI-CSI I2C / Trigger (Common)
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	input 			csi_trig_i,
	output 			csi_trig_o,
	output 			csi_trig_oe,
	
	//	MOSI_D0 | CSI_SCL
	//	MISO_D1 | CSI_SDA 
	//	SPI_SCK | CSI2_SCL
	input 			csi2_sda_i, 
	output 			csi2_sda_o, 
	output 			csi2_sda_oe, 
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	MIPI-CSI0 Data
	input 			csi_rxc_lp_p_i,
	input 			csi_rxc_lp_n_i,
	output 			csi_rxc_hs_en_o,
	output 			csi_rxc_hs_term_en_o,
	input 			csi_rxc_i,
	
	output 			csi_rxd0_rst_o,
	output 			csi_rxd0_hs_en_o,
	output 			csi_rxd0_hs_term_en_o,
	
	input 			csi_rxd0_lp_p_i,
	input 			csi_rxd0_lp_n_i,
	input 	[7:0] 	csi_rxd0_hs_i,
	
	output 			csi_rxd1_rst_o,
	output 			csi_rxd1_hs_en_o,
	output 			csi_rxd1_hs_term_en_o,
	
	input 			csi_rxd1_lp_p_i,
	input 			csi_rxd1_lp_n_i,
	input 	[7:0] 	csi_rxd1_hs_i,
	
	output 			csi_rxd2_rst_o,
	output 			csi_rxd2_hs_en_o,
	output 			csi_rxd2_hs_term_en_o,
	
	input 			csi_rxd2_lp_p_i,
	input 			csi_rxd2_lp_n_i,
	input 	[7:0] 	csi_rxd2_hs_i,
	
	output 			csi_rxd3_rst_o,
	output 			csi_rxd3_hs_en_o,
	output 			csi_rxd3_hs_term_en_o,
	
	input 			csi_rxd3_lp_p_i,
	input 			csi_rxd3_lp_n_i,
	input 	[7:0] 	csi_rxd3_hs_i,
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	MIPI-CSI1 Data
	input 			csi2_rxc_lp_p_i,
	input 			csi2_rxc_lp_n_i,
	output 			csi2_rxc_hs_en_o,
	output 			csi2_rxc_hs_term_en_o,
	input 			csi2_rxc_i,
	
	output 			csi2_rxd0_rst_o,
	output 			csi2_rxd0_hs_en_o,
	output 			csi2_rxd0_hs_term_en_o,
	
	input 			csi2_rxd0_lp_p_i,
	input 			csi2_rxd0_lp_n_i,
	input 	[7:0] 	csi2_rxd0_hs_i,
	
	output 			csi2_rxd1_rst_o,
	output 			csi2_rxd1_hs_en_o,
	output 			csi2_rxd1_hs_term_en_o,
	
	input 			csi2_rxd1_lp_p_i,
	input 			csi2_rxd1_lp_n_i,
	input 	[7:0] 	csi2_rxd1_hs_i,
	
	output 			csi2_rxd2_rst_o,
	output 			csi2_rxd2_hs_en_o,
	output 			csi2_rxd2_hs_term_en_o,
	
	input 			csi2_rxd2_lp_p_i,
	input 			csi2_rxd2_lp_n_i,
	input 	[7:0] 	csi2_rxd2_hs_i,
	
	output 			csi2_rxd3_rst_o,
	output 			csi2_rxd3_hs_en_o,
	output 			csi2_rxd3_hs_term_en_o,
	
	input 			csi2_rxd3_lp_p_i,
	input 			csi2_rxd3_lp_n_i,
	input 	[7:0] 	csi2_rxd3_hs_i,
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DSI-TX Control & Data
	output 			dsi_pwm_o,			//	MIPI-DSI LCD PWM
	
	//	MIPI-DSI TXC / TXD (N/A)
	output 			dsi_txc_rst_o,
	output 			dsi_txc_lp_p_oe,
	output 			dsi_txc_lp_p_o,
	output 			dsi_txc_lp_n_oe,
	output 			dsi_txc_lp_n_o,
	output 			dsi_txc_hs_oe,
	output 	[7:0] 	dsi_txc_hs_o,
	
	output 			dsi_txd0_rst_o,
	output 			dsi_txd0_hs_oe,
	output 	[7:0] 	dsi_txd0_hs_o,
	output 			dsi_txd0_lp_p_oe,
	output 			dsi_txd0_lp_p_o,
	output 			dsi_txd0_lp_n_oe,
	output 			dsi_txd0_lp_n_o,
	
	output 			dsi_txd1_rst_o,
	output 			dsi_txd1_lp_p_oe,
	output 			dsi_txd1_lp_p_o,
	output 			dsi_txd1_lp_n_oe,
	output 			dsi_txd1_lp_n_o,
	output 			dsi_txd1_hs_oe,
	output 	[7:0] 	dsi_txd1_hs_o,
	
	output 			dsi_txd2_rst_o,
	output 			dsi_txd2_lp_p_oe,
	output 			dsi_txd2_lp_p_o,
	output 			dsi_txd2_lp_n_oe,
	output 			dsi_txd2_lp_n_o,
	output 			dsi_txd2_hs_oe,
	output 	[7:0] 	dsi_txd2_hs_o,
	
	output 			dsi_txd3_rst_o,
	output 			dsi_txd3_lp_p_oe,
	output 			dsi_txd3_lp_p_o,
	output 			dsi_txd3_lp_n_oe,
	output 			dsi_txd3_lp_n_o,
	output 			dsi_txd3_hs_oe,
	output 	[7:0] 	dsi_txd3_hs_o,
	
	input 			dsi_txd0_lp_p_i,
	input 			dsi_txd0_lp_n_i,
	input 			dsi_txd1_lp_p_i,
	input 			dsi_txd1_lp_n_i,
	input 			dsi_txd2_lp_p_i,
	input 			dsi_txd2_lp_n_i,
	input 			dsi_txd3_lp_p_i,
	input 			dsi_txd3_lp_n_i,
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	CSI-TX Control & Data
	input 			csi_tx_scl_i, 		
	output 			csi_tx_scl_o, 
	output 			csi_tx_scl_oe, 
	
	input 			csi_tx_sda_i, 		
	output 			csi_tx_sda_o, 
	output 			csi_tx_sda_oe, 
	
	
	//	MIPI-DSI TXC / TXD (N/A)
	output 			csi_txc_rst_o,
	output 			csi_txc_lp_p_oe,
	output 			csi_txc_lp_p_o,
	output 			csi_txc_lp_n_oe,
	output 			csi_txc_lp_n_o,
	output 			csi_txc_hs_oe,
	output 	[7:0] 	csi_txc_hs_o,
	
	output 			csi_txd0_rst_o,
	output 			csi_txd0_hs_oe,
	output 	[7:0] 	csi_txd0_hs_o,
	output 			csi_txd0_lp_p_oe,
	output 			csi_txd0_lp_p_o,
	output 			csi_txd0_lp_n_oe,
	output 			csi_txd0_lp_n_o,
	
	output 			csi_txd1_rst_o,
	output 			csi_txd1_lp_p_oe,
	output 			csi_txd1_lp_p_o,
	output 			csi_txd1_lp_n_oe,
	output 			csi_txd1_lp_n_o,
	output 			csi_txd1_hs_oe,
	output 	[7:0] 	csi_txd1_hs_o,
	
	output 			csi_txd2_rst_o,
	output 			csi_txd2_lp_p_oe,
	output 			csi_txd2_lp_p_o,
	output 			csi_txd2_lp_n_oe,
	output 			csi_txd2_lp_n_o,
	output 			csi_txd2_hs_oe,
	output 	[7:0] 	csi_txd2_hs_o,
	
	output 			csi_txd3_rst_o,
	output 			csi_txd3_lp_p_oe,
	output 			csi_txd3_lp_p_o,
	output 			csi_txd3_lp_n_oe,
	output 			csi_txd3_lp_n_o,
	output 			csi_txd3_hs_oe,
	output 	[7:0] 	csi_txd3_hs_o,
	
	input 			csi_txd0_lp_p_i,
	input 			csi_txd0_lp_n_i,
	input 			csi_txd1_lp_p_i,
	input 			csi_txd1_lp_n_i,
	input 			csi_txd2_lp_p_i,
	input 			csi_txd2_lp_n_i,
	input 			csi_txd3_lp_p_i,
	input 			csi_txd3_lp_n_i,
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	HDMI
	output 			hdmi_txc_oe,
	output 			hdmi_txd0_oe,
	output 			hdmi_txd1_oe,
	output 			hdmi_txd2_oe,
	
	output 			hdmi_txc_rst_o,
	output 			hdmi_txd0_rst_o,
	output 			hdmi_txd1_rst_o,
	output 			hdmi_txd2_rst_o,
	
	output 	[9:0] 	hdmi_txc_o,
	output 	[9:0] 	hdmi_txd0_o,
	output 	[9:0] 	hdmi_txd1_o,
	output 	[9:0] 	hdmi_txd2_o,
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	HBRAM Interface
	//	HBRAM. Has CK, CS, RSTN, DQ, RWDS signals. 
	output 			hbram_CK_P_HI,
	output 			hbram_CK_P_LO,
	output 			hbram_CK_N_HI,
	output 			hbram_CK_N_LO,
	
	output 			hbram_CS_N,
	output 			hbram_RST_N,
	
	output 	[15:0] 	hbram_DQ_OUT_HI,
	output 	[15:0] 	hbram_DQ_OUT_LO,
	output 	[15:0] 	hbram_DQ_OE,
	input 	[15:0] 	hbram_DQ_IN_HI,
	input 	[15:0] 	hbram_DQ_IN_LO,
	
	output 	[1:0] 	hbram_RWDS_OUT_HI,
	output 	[1:0] 	hbram_RWDS_OUT_LO,
	output 	[1:0] 	hbram_RWDS_OE, 
	input 	[1:0] 	hbram_RWDS_IN_HI,
	input 	[1:0] 	hbram_RWDS_IN_LO,


	input                   i_clk, 	
	input                   i_rst_n, 	 		
	output					o_gray_hsyn,	
	output  				o_gray_vsyn,	
	output  	[23:0]		o_gray_data,	
	output  				o_gray_de
			
);
	
	genvar _i; 
	
	parameter 	SIM_DATA 	= 0; 
	
	//	RXC Shall Not Be Inverted. 
	parameter 	CSI0_BITFLIP 	= 5'b00011; 	//	[4]CLK, [3]D3, [2]D2, [1]D1, [0]D0
	parameter 	CSI1_BITFLIP 	= 5'b01100; 	//	[4]CLK, [3]D3, [2]D2, [1]D1, [0]D0
	
	parameter 	DSI_TX_BITFLIP 	= 5'b00000; 	//	[4]CLK, [3]D3, [2]D2, [1]D1, [0]D0
	parameter 	CSI_TX_BITFLIP 	= 5'b11111; 	//	[4]CLK, [3]D3, [2]D2, [1]D1, [0]D0
	
	parameter 	HDMI_BITFLIP 	= 4'b0111; 		//	[3]CLK, [2]D2, [1]D1, [0]D0
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	Static Configuration. Trigger not implemented. 
	assign csi_trig_o = 1'b1; 	
	assign csi_trig_oe = 1'b1; 
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	Clock & Reset
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//	HDMI PLL must be deasserted. 
	assign hdmi_pll_rstn_o = 1'b1; 
	
	
	//	Mux PLL Lock
	wire 			w_syspll_lock_i = hdmi_pll_lock; 
	wire 			w_pll_lock_i = w_syspll_lock_i && hbramClk_pll_lock && dsi_pll_lock; 
	
	
	//	Reset of hdmi_pll. Wait for hdmi_pll_lock to release hyperRAM / DSI reset. 
	wire 			w_syspll_locked; 
	Reset rst_syspll (.clk_i(sys_clk_i), .locked_i(w_syspll_lock_i), .rstn_o(w_syspll_locked), .rst_o()); 
	assign hbramClk_pll_rstn_o = w_syspll_locked; 
	assign dsi_pll_rstn_o = w_syspll_locked; 
	
	
	//	HBRAM Reset (247.5MHz)
	wire 			w_hbram_clk = hbramClk; 
	wire 			w_hbram_rst, w_hbram_rstn; 
	Reset rst_hbrampll (.clk_i(w_hbram_clk), .locked_i(w_pll_lock_i), .rstn_o(w_hbram_rstn), .rst_o(w_hbram_rst)); 
	
	
	//	Pixel Reset (148.5MHz)
	wire 			w_pixel_clk = hdmi_pixel; 
	wire 			w_pixel_rst, w_pixel_rstn; 
	Reset rst_pixel (.clk_i(w_pixel_clk), .locked_i(w_pll_lock_i), .rstn_o(w_pixel_rstn), .rst_o(w_pixel_rst)); 
	
	
	//	System Clock & Reset (148.5MHz)
	wire 			w_sys_clk = hdmi_pixel;
	wire 			w_sys_rst, w_sys_rstn; 
	Reset rst_sysclk (.clk_i(w_sys_clk), .locked_i(w_pll_lock_i), .rstn_o(w_sys_rstn), .rst_o(w_sys_rst)); 
	
	
	//	Slow Clock (27MHz)
	wire 			w_xclk = sensor_xclk_i;
	wire 			w_xrst, w_xrstn; 
	Reset rst_xclk (.clk_i(w_xclk), .locked_i(w_pll_lock_i), .rstn_o(w_xrstn), .rst_o(w_xrst)); 
	
	
	//	AXI Clock will use sys_clk. (148.5MHz) 
	wire 			w_axi_clk = w_sys_clk; 
	wire 			w_axi_rst = w_sys_rst; 
	wire 			w_axi_rstn = w_sys_rstn; 
	
	
	//	System Clock (for SOC / IIC / etc)
	localparam 	CLOCK_MAIN 	= 99000000; 	//	System clock using 96MHz. 
	localparam 	BAUD_RATE 	= 115200; 		//	Use 115200-8-N-1 UART baud rate. The hardware cannot support higher baud rates. 
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	Flash Burner Control
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire 			w_ustick, w_mstick; 
	
	wire  [7:0] 	w_dev_index_o;  
	wire  [7:0] 	w_dev_cmd_o;  
	wire  [31:0] 	w_dev_wdata_o;  
	wire  		w_dev_wvalid_o;  
	wire  		w_dev_rvalid_o;  
	wire 	[31:0] 	w_dev_rdata_i;  
	
	wire 	[3:0] 	w_scl_o, w_scl_oe, w_sda_o, w_sda_oe, w_sda_i; 
	
	wire 			w_spi_ssn_o, w_spi_sck_o; 
	wire 	[3:0] 	w_spi_data_o, w_spi_data_oe; 
	wire 	[3:0] 	w_spi_data_i; 
	
	wire 			w_soc_runz; 
	
	
	//	LED
	//assign led_o = w_soc_runz; 	
	
	//	Flash Control
	reg 			r_flash_en = 0; 		//	0x00:0x00 Enable Flash
	always @(posedge w_sys_clk) begin
		r_flash_en <= (w_dev_wvalid_o && (w_dev_index_o == 8'h00) && (w_dev_cmd_o == 8'h00)) ? w_dev_wdata_o : r_flash_en; 
	end
	
	
	
	
	
	
	
	
	
	
	
	// ////////////////////////////////////////////////////////////////
	// //	I2C Config (SC130GS)
	
	// //  i2c timing controller module of 16Bit
	// wire            [ 8:0]          sc2210_i2c_config_index;
	// wire            [23:0]          sc2210_i2c_config_data;
	// wire            [ 8:0]          sc2210_i2c_config_size;
	// wire                            sc2210_i2c_config_done;
	
	// wire 			w_i2c0_scl_o, w_i2c0_sda_i, w_i2c0_sda_o, w_i2c0_sda_oe; 
	
	// i2c_timing_ctrl_reg16_dat8_wronly
	// #(
	//     .CLK_FREQ           (CLOCK_MAIN),                              //  100 MHz
	//     .I2C_FREQ           (50_000    )                               //  10 KHz(<= 400KHz)
	// ) u_i2c_timing_ctrl_16bit (
	//     //  global clock
	//     .clk                (w_sys_clk                 ),                          //  96MHz
	//     .rst_n              (w_sys_rstn                ),                          //  system reset

	//     //  i2c interface
	//     .i2c_sclk           (w_i2c0_scl_o               ),                          //  i2c clock
	//     .i2c_sdat_IN        (w_i2c0_sda_i               ),
	//     .i2c_sdat_OUT       (w_i2c0_sda_o               ),
	//     .i2c_sdat_OE        (w_i2c0_sda_oe              ),

	//     //  i2c config data
	//     .i2c_config_index   (sc2210_i2c_config_index        ),                          //  i2c config reg index, read 2 reg and write xx reg
	//     .i2c_config_data    ({8'h60, sc2210_i2c_config_data}),                     //  i2c config data
	//     .i2c_config_size    (sc2210_i2c_config_size         ),                          //  i2c config data counte
	//     .i2c_config_done    (sc2210_i2c_config_done         )                          //  i2c config timing complete
	// );

	// //  I2C Configure Data of SC2210
	// I2C_SC2210_19201080_4Lanes_Config u_I2C_SC2210_19201080_4Lanes_Config
	// (
	//     .LUT_INDEX  (sc2210_i2c_config_index   ),
	//     .LUT_DATA   (sc2210_i2c_config_data    ),
	//     .LUT_SIZE   (sc2210_i2c_config_size    )
	// );
	////////////////////////////////////////////////////////////////
	//	I2C Config (SC130GS)
	
	// i2c timing controller module of 16Bit
	wire            [ 8:0]          sc2210_i2c_config_index;
	wire            [23:0]          sc2210_i2c_config_data;
	wire            [ 8:0]          sc2210_i2c_config_size;
	wire                            sc2210_i2c_config_done;
	
	wire 			w_i2c0_scl_o, w_i2c0_sda_i, w_i2c0_sda_o, w_i2c0_sda_oe; 
	
    i2c_timing_ctrl_16bit
    #(
    .CLK_FREQ                          (CLOCK_MAIN                ),//  100 MHz
    .I2C_FREQ                          (100_000                    ) //  10 KHz(<= 400KHz)
    ) u_i2c_timing_ctrl_16bit (
	    //  global clock
    .clk                               (sys_clk_i                   ),//  96MHz
    .rst_n                             (w_pixel_rstn                  ),//  system reset

	    //  i2c interface
    .i2c_sclk                          (w_i2c0_scl_o                 ),//  i2c clock
    .i2c_sdat_IN                       (w_i2c0_sda_i                 ),
    .i2c_sdat_OUT                      (w_i2c0_sda_o                 ),
    .i2c_sdat_OE                       (w_i2c0_sda_oe                  ),

	    //  i2c config data
    .i2c_config_index                  (sc2210_i2c_config_index    ),//  i2c config reg index, read 2 reg and write xx reg
    .i2c_config_data                   ({8'h60, sc2210_i2c_config_data}),//  i2c config data
    .i2c_config_size                   (sc2210_i2c_config_size     ),//  i2c config data counte
    .i2c_config_done                   (sc2210_i2c_config_done     ) //  i2c config timing complete
    );
    assign csi_scl_oe = 1;

	//  I2C Configure Data of SC130GS
    I2C_SC130GS_12801024_4Lanes_Config u_I2C_SC130GS_12801024_4Lanes_Config
    (
    .LUT_INDEX                         (sc2210_i2c_config_index    ),
    .LUT_DATA                          (sc2210_i2c_config_data     ),
    .LUT_SIZE                          (sc2210_i2c_config_size     ) 
    );
	
	
	
	assign w_scl_o[0] = w_i2c0_scl_o; 
	assign w_scl_oe[0] = 1; 
	assign w_sda_o[0] = w_i2c0_sda_o; 
	assign w_sda_oe[0] = w_i2c0_sda_oe; 
	assign w_i2c0_sda_i = w_sda_i[0]; 
	
	
	
	
	
	
	
	
	//	SPI / I2C Data Connection.
	//	MOSI_D0 | CSI_SCL
	//	MISO_D1 | CSI_SDA 
	//	SPI_SCK | CSI2_SCL
	assign spi_cs_o = r_flash_en ? w_spi_ssn_o : 1'b1; 				//	Enable flash SSN when r_flash_en. 
	assign spi_cs_oe = 1'b1; 	
	
	assign spi_sck_o = r_flash_en ? w_spi_sck_o : w_scl_o[1]; 			//	SPI_SCK | CSI2_SCL
	assign spi_sck_oe = r_flash_en ? 1'b1 : w_scl_oe[1]; 		
	
	assign w_spi_data_i[0] = spi_mosi_d0_i; 				
	assign spi_mosi_d0_o = r_flash_en ? w_spi_data_o[0] : w_scl_o[0]; 	//	MOSI_D0 | CSI_SCL
	assign spi_mosi_d0_oe = r_flash_en ? w_spi_data_oe[0] : w_scl_oe[0]; 	
	
	assign w_spi_data_i[1] = spi_miso_d1_i; 				
	assign spi_miso_d1_o = r_flash_en ? w_spi_data_o[1] : w_sda_o[0]; 	//	MISO_D1 | CSI_SDA 
	assign spi_miso_d1_oe = r_flash_en ? w_spi_data_oe[1] : w_sda_oe[0]; 	
	assign w_sda_i[0] = spi_miso_d1_i; 
	
	assign w_spi_data_i[2] = spi_wpn_d2_i; 				
	assign spi_wpn_d2_o = r_flash_en ? w_spi_data_o[2] : 1'b1; 			//	WPn
	assign spi_wpn_d2_oe = r_flash_en ? w_spi_data_oe[2] : 1'b1; 	
	
	assign w_spi_data_i[3] = spi_holdn_d3_i; 				
	assign spi_holdn_d3_o = r_flash_en ? w_spi_data_o[3] : 1'b1; 		//	HOLDn
	assign spi_holdn_d3_oe = r_flash_en ? w_spi_data_oe[3] : 1'b1; 	
	
	assign w_sda_i[1] = csi2_sda_i; 
	assign csi2_sda_o = w_sda_o[1]; 
	assign csi2_sda_oe = w_sda_oe[1]; 
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DSI PWM Registers
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	reg 	[7:0] 	r_dsi_pwm = 0; 
	always @(posedge sys_clk_i) begin
		r_dsi_pwm 	<= (w_dev_wvalid_o && (w_dev_index_o == 8'h00) && (w_dev_cmd_o == 8'h03)) ? w_dev_wdata_o : r_dsi_pwm; 
	end
	
	//	PWM Gen. When 0, disable backlight output. 
	reg 	[11:0] 	rc_pwm = 0; 
	reg 			r_dsi_pwm_o = 0; 
	always @(posedge sys_clk_i) begin
		rc_pwm <= rc_pwm + 1; 
		r_dsi_pwm_o <= ({r_dsi_pwm, 4'b0} > rc_pwm); 
	end
	assign dsi_pwm_o = r_dsi_pwm_o; 
	
	
	
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	HyperRAM Controller
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	wire			w_hbram_ui_clk = w_sys_clk;
	wire			w_hbram_ui_rst = w_sys_rst;
	wire			w_hbram_ui_areset = w_sys_rst;
	wire			w_hbram_ui_aresetn = w_sys_rstn;
	
	
	//	General AXI Interface 
	wire	[3:0] 	w_hbram_awid;
	wire	[31:0]	w_hbram_awaddr;
	wire	[7:0]		w_hbram_awlen;
	wire			w_hbram_awvalid;
	wire			w_hbram_awready;
	
	wire 	[3:0]  	w_hbram_wid;
	wire 	[127:0] 	w_hbram_wdata;
	wire 	[15:0]	w_hbram_wstrb;
	wire			w_hbram_wlast;
	wire			w_hbram_wvalid;
	wire			w_hbram_wready;
	
	wire 	[3:0] 	w_hbram_bid;
	wire 	[1:0] 	w_hbram_bresp;
	wire			w_hbram_bvalid;
	wire			w_hbram_bready;
	
	wire	[3:0] 	w_hbram_arid;
	wire	[31:0]	w_hbram_araddr;
	wire	[7:0]		w_hbram_arlen;
	wire			w_hbram_arvalid;
	wire			w_hbram_arready;
	
	wire 	[3:0] 	w_hbram_rid;
	wire 	[127:0] 	w_hbram_rdata;
	wire			w_hbram_rlast;
	wire			w_hbram_rvalid;
	wire			w_hbram_rready;
	wire 	[1:0] 	w_hbram_rresp;
	
	
	//	AXI Interface Request
	wire 	[3:0] 	w_hbram_aid;
	wire 	[31:0] 	w_hbram_aaddr;
	wire 	[7:0]  	w_hbram_alen;
	wire 	[2:0]  	w_hbram_asize;
	wire 	[1:0]  	w_hbram_aburst;
	wire 	[1:0]  	w_hbram_alock;
	wire			w_hbram_avalid;
	wire			w_hbram_aready;
	wire			w_hbram_atype;
	
	wire 			w_hbram_cal_pass; 
	wire 			w_hbram_cal_done = w_hbram_cal_pass; 
	wire 	[15:0] 	w_hbram_cal_dbg; 
	
	assign w_dev_rdata_i = {w_hbram_cal_dbg, 15'h0, w_hbram_cal_pass}; 
	
	hbram u_hbram (		
		.ram_clk			(hbramClk),			//	input ram_clk,
		.ram_clk_cal		(hbramClk_Cal),		//	input ram_clk_cal,
		.io_axi_clk			(sys_clk_i),		//	input io_axi_clk,
		.rst				(w_hbram_ui_areset),	//	input rst,
		
		.hbc_cal_SHIFT_SEL	(hbramClk_shift_sel),	//	output [4:0] hbc_cal_SHIFT_SEL,
		.hbc_cal_SHIFT		(hbramClk_shift),		//	output [2:0] hbc_cal_SHIFT,
		.hbc_cal_SHIFT_ENA	(hbramClk_shift_ena),	//	output hbc_cal_SHIFT_ENA,
		.hbc_cal_debug_info	(w_hbram_cal_dbg),		//	output [15:0] hbc_cal_debug_info,
		.hbc_cal_pass		(w_hbram_cal_pass),	//	output hbc_cal_pass,
		
		.dyn_pll_phase_sel	(0),				//	input [2:0] dyn_pll_phase_sel,
		.dyn_pll_phase_en		(0),				//	input dyn_pll_phase_en,
		
		.io_arw_payload_addr	(w_hbram_aaddr),		//	input [31:0] io_arw_payload_addr,
		.io_arw_payload_id	(w_hbram_aid),		//	input [7:0] io_arw_payload_id,
		.io_arw_payload_len	(w_hbram_alen),		//	input [7:0] io_arw_payload_len,
		.io_arw_payload_size	(w_hbram_asize),		//	input [2:0] io_arw_payload_size,
		.io_arw_payload_burst	(w_hbram_aburst),		//	input [1:0] io_arw_payload_burst,
		.io_arw_payload_lock	(w_hbram_alock),		//	input [1:0] io_arw_payload_lock,
		.io_arw_payload_write	(w_hbram_atype),		//	input io_arw_payload_write, 		//	0:Read. 1:Write
		.io_arw_valid		(w_hbram_avalid),		//	input io_arw_valid,
		.io_arw_ready		(w_hbram_aready),		//	output io_arw_ready,
			
		.io_w_payload_id		(w_hbram_wid),		//	input [7:0] io_w_payload_id,
		.io_w_payload_data	(w_hbram_wdata),		//	input [127:0] io_w_payload_data,
		.io_w_payload_strb	(w_hbram_wstrb),		//	input [15:0] io_w_payload_strb,
		.io_w_payload_last 	(w_hbram_wlast),		//	input io_w_payload_last,	
		.io_w_valid			(w_hbram_wvalid),		//	input io_w_valid,
		.io_w_ready			(w_hbram_wready),		//	output io_w_ready,
		
		.io_b_payload_id		(w_hbram_bid),		//	output [7:0] io_b_payload_id,
		.io_b_valid			(w_hbram_bvalid),		//	output io_b_valid,
		.io_b_ready			(w_hbram_bready),		//	input io_b_ready,

		.io_r_payload_id		(w_hbram_rid),		//	output [7:0] io_r_payload_id,
		.io_r_payload_data	(w_hbram_rdata),		//	output [127:0] io_r_payload_data,
		.io_r_payload_last	(w_hbram_rlast),		//	output io_r_payload_last,
		.io_r_payload_resp	(w_hbram_rresp),		//	output [1:0] io_r_payload_resp
		.io_r_valid			(w_hbram_rvalid),		//	output io_r_valid,
		.io_r_ready			(w_hbram_rready),		//	input io_r_ready,
		
		.hbc_ck_p_HI		(hbram_CK_P_HI),		//	output hbc_ck_p_HI,
		.hbc_ck_p_LO		(hbram_CK_P_LO),		//	output hbc_ck_p_LO,
		.hbc_ck_n_HI		(hbram_CK_N_HI),		//	output hbc_ck_n_HI,
		.hbc_ck_n_LO		(hbram_CK_N_LO),		//	output hbc_ck_n_LO,
		.hbc_cs_n			(hbram_CS_N),		//	output hbc_cs_n,
		.hbc_rst_n			(hbram_RST_N),		//	output hbc_rst_n,

		.hbc_dq_OUT_HI		(hbram_DQ_OUT_HI),	//	output [15:0] hbc_dq_OUT_HI,
		.hbc_dq_OUT_LO		(hbram_DQ_OUT_LO),	//	output [15:0] hbc_dq_OUT_LO,
		.hbc_dq_OE			(hbram_DQ_OE),		//	output [15:0] hbc_dq_OE,
		.hbc_dq_IN_HI		(hbram_DQ_IN_HI),		//	input [15:0] hbc_dq_IN_HI,
		.hbc_dq_IN_LO		(hbram_DQ_IN_LO),		//	input [15:0] hbc_dq_IN_LO,
		
		.hbc_rwds_OUT_HI		(hbram_RWDS_OUT_HI),	//	output [1:0] hbc_rwds_OUT_HI,
		.hbc_rwds_OUT_LO		(hbram_RWDS_OUT_LO),	//	output [1:0] hbc_rwds_OUT_LO,
		.hbc_rwds_OE		(hbram_RWDS_OE),		//	output [1:0] hbc_rwds_OE,
		.hbc_rwds_IN_HI		(hbram_RWDS_IN_HI),	//	input [1:0] hbc_rwds_IN_HI,
		.hbc_rwds_IN_LO		(hbram_RWDS_IN_LO)	//	input [1:0] hbc_rwds_IN_LO,
	);
	assign w_hbram_bready = 1'b1; 
	
	AXI4_AWARMux #(.AID_LEN(4), .AADDR_LEN(32)) axi4_awar_mux (
		.aclk_i			(sys_clk_i), 
		.arst_i			(w_hbram_ui_rst), 
		
		.awid_i			(w_hbram_awid),
		.awaddr_i			(w_hbram_awaddr),
		.awlen_i			(w_hbram_awlen),
		//.awvalid_i			(w_hbram_awvalid && w_hbram_cal_pass),
		.awvalid_i			(w_hbram_awvalid ),
		.awready_o			(w_hbram_awready),
		
		.arid_i			(w_hbram_arid),
		.araddr_i			(w_hbram_araddr),
		.arlen_i			(w_hbram_arlen),
		//.arvalid_i			(w_hbram_arvalid && w_hbram_cal_pass),
		.arvalid_i			(w_hbram_arvalid ),
		.arready_o			(w_hbram_arready),
		
		.aid_o			(w_hbram_aid),
		.aaddr_o			(w_hbram_aaddr),
		.alen_o			(w_hbram_alen),
		.atype_o			(w_hbram_atype),
		.avalid_o			(w_hbram_avalid),
		.aready_i			(w_hbram_aready)
	);
	assign w_hbram_asize = 4; 		//	Fixed 128 bits (16 bytes, size = 4)
	assign w_hbram_aburst = 1; 
	assign w_hbram_alock = 0; 
	
	
	

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	MIPI CSI RX (Use CSI0_BITFLIP For Bit Flip)
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	//	Current implementation supports RAW8 only. 
	wire 			w_csi_rx_clk; 
	wire 			w_csi_rx_vsync0, w_csi_rx_hsync0, w_csi_rx_dvalid; 
	wire 	[63:0] 	w_csi_rx_data; 
	wire 	[47:0] 	w_csi_rx_data_rel_raw; 
	
	//	AXI Interface
	wire 	[31:0] 	w_csi_axi_rdata; 
	wire 			w_csi_axi_awready, w_csi_axi_wready, w_csi_axi_arready, w_csi_axi_rvalid; 
	
//`define PRI_MIPI_IP
	
`ifdef PRI_MIPI_IP
	//localparam 	CSI_DATA_WIDTH 	= 64; 	
	localparam 	CSI_DATA_WIDTH 	= 32; 			
	localparam 	CSI_STRB_WIDTH 	= CSI_DATA_WIDTH / 8; 
	
	wire 	[7:0] 	w_mipi_d0 = (CSI0_BITFLIP[0] ? 8'hFF : 8'h00) ^ csi_rxd0_hs_i; 
	wire 	[7:0] 	w_mipi_d1 = (CSI0_BITFLIP[1] ? 8'hFF : 8'h00) ^ csi_rxd1_hs_i; 
	wire 	[7:0] 	w_mipi_d2 = (CSI0_BITFLIP[2] ? 8'hFF : 8'h00) ^ csi_rxd2_hs_i; 
	wire 	[7:0] 	w_mipi_d3 = (CSI0_BITFLIP[3] ? 8'hFF : 8'h00) ^ csi_rxd3_hs_i; 
	MIPIRx4LaneFre mipi0_rx (
		.sclk_i			(w_sys_clk), 
		.srst_i			(w_sys_rst), 
		
		.mipi_rx_byteclk_i	(csi_rxc_i), 
		.mipi_rx_d0_i		({w_mipi_d0[0], w_mipi_d0[1], w_mipi_d0[2], w_mipi_d0[3], w_mipi_d0[4], w_mipi_d0[5], w_mipi_d0[6], w_mipi_d0[7]}), 
		.mipi_rx_d1_i		({w_mipi_d1[0], w_mipi_d1[1], w_mipi_d1[2], w_mipi_d1[3], w_mipi_d1[4], w_mipi_d1[5], w_mipi_d1[6], w_mipi_d1[7]}), 
		.mipi_rx_d2_i		({w_mipi_d2[0], w_mipi_d2[1], w_mipi_d2[2], w_mipi_d2[3], w_mipi_d2[4], w_mipi_d2[5], w_mipi_d2[6], w_mipi_d2[7]}), 
		.mipi_rx_d3_i		({w_mipi_d3[0], w_mipi_d3[1], w_mipi_d3[2], w_mipi_d3[3], w_mipi_d3[4], w_mipi_d3[5], w_mipi_d3[6], w_mipi_d3[7]}), 
		.mipi_rx_clk_lp_p_i	(csi_rxc_lp_p_i), 
		.mipi_rx_clk_lp_n_i	(csi_rxc_lp_n_i), 
		.mipi_rx_d0_lp_p_i	(CSI0_BITFLIP[0] ? csi_rxd0_lp_n_i : csi_rxd0_lp_p_i), 
		.mipi_rx_d0_lp_n_i	(CSI0_BITFLIP[0] ? csi_rxd0_lp_p_i : csi_rxd0_lp_n_i), 
		.mipi_rx_rst_o		(), 
		.mipi_rx_rst_n_o		(), 
		.mipi_rx_clk_hs_en_o	(csi_rxc_hs_en_o), 
		.mipi_rx_dat_hs_en_o	(csi_rxd0_hs_en_o), 
		.mipi_rx_clk_term_en_o	(csi_rxc_hs_term_en_o), 
		.mipi_rx_dat_term_en_o	(csi_rxd0_hs_term_en_o), 
		
		.CLK				(w_csi_rx_clk), 
		.VSYNC			(w_csi_rx_vsync0), 
		.HSYNC			(w_csi_rx_hsync0), 
		.DE				(w_csi_rx_dvalid), 
		.DAT				(w_csi_rx_data_rel_raw)
	);
	assign w_csi_rx_data = {2{w_csi_rx_data_rel_raw[47:40], w_csi_rx_data_rel_raw[35:28], w_csi_rx_data_rel_raw[23:16], w_csi_rx_data_rel_raw[11:4]}}; 
	assign {csi_rxd3_hs_en_o, csi_rxd2_hs_en_o, csi_rxd1_hs_en_o} = {3{csi_rxd0_hs_en_o}}; 
	assign {csi_rxd3_hs_term_en_o, csi_rxd2_hs_term_en_o, csi_rxd1_hs_term_en_o} = {3{csi_rxd0_hs_term_en_o}}; 
	
	
`else	
	localparam 	CSI_DATA_WIDTH 	= 64; 			
	localparam 	CSI_STRB_WIDTH 	= CSI_DATA_WIDTH / 8; 
	
	//	Reset pixel 16 cycles after ~vsync. 
	reg 			r_reset_pixen_n = 0; 
	reg 	[1:0] 	r_csi_rx_vsync0_i = 0; 
	always @(posedge w_csi_rx_clk or negedge w_sys_rstn) begin
		if(~w_sys_rstn) begin
			r_reset_pixen_n <= 0; 
			r_csi_rx_vsync0_i <= 0; 
		end else begin
			r_csi_rx_vsync0_i <= {r_csi_rx_vsync0_i, w_csi_rx_vsync0}; 
			r_reset_pixen_n <= (r_csi_rx_vsync0_i == 2'b10) ? 1'b0 : 1'b1; 
		end
	end
	
	assign w_csi_rx_clk =sys_clk_i;
	//assign w_csi_rx_clk = w_sys_clk; 
	csi_rx mipi_rx_0(
		.reset_n			(w_sys_rstn), 
		.clk				(w_csi_rx_clk), 
		.reset_byte_HS_n		(w_sys_rstn), 
		.clk_byte_HS		(csi_rxc_i), 
		.reset_pixel_n		(r_reset_pixen_n), 	//w_sys_rstn), 
		.clk_pixel			(w_csi_rx_clk), 
		.Rx_LP_CLK_P		(csi_rxc_lp_p_i), 
		.Rx_LP_CLK_N		(csi_rxc_lp_n_i), 
		
		.Rx_HS_enable_C		(csi_rxc_hs_en_o), 
		.LVDS_termen_C		(csi_rxc_hs_term_en_o), 
		
		//	Lane inversion affects HS & LP data only. 
		.Rx_LP_D_P			({CSI0_BITFLIP[3] ? csi_rxd3_lp_n_i : csi_rxd3_lp_p_i, CSI0_BITFLIP[2] ? csi_rxd2_lp_n_i : csi_rxd2_lp_p_i, CSI0_BITFLIP[1] ? csi_rxd1_lp_n_i : csi_rxd1_lp_p_i, CSI0_BITFLIP[0] ? csi_rxd0_lp_n_i : csi_rxd0_lp_p_i}), 
		.Rx_LP_D_N			({CSI0_BITFLIP[3] ? csi_rxd3_lp_p_i : csi_rxd3_lp_n_i, CSI0_BITFLIP[2] ? csi_rxd2_lp_p_i : csi_rxd2_lp_n_i, CSI0_BITFLIP[1] ? csi_rxd1_lp_p_i : csi_rxd1_lp_n_i, CSI0_BITFLIP[0] ? csi_rxd0_lp_p_i : csi_rxd0_lp_n_i}), 
		.Rx_HS_D_0			((CSI0_BITFLIP[0] ? 8'hFF : 8'h00) ^ csi_rxd0_hs_i), 
		.Rx_HS_D_1			((CSI0_BITFLIP[1] ? 8'hFF : 8'h00) ^ csi_rxd1_hs_i), 
		.Rx_HS_D_2			((CSI0_BITFLIP[2] ? 8'hFF : 8'h00) ^ csi_rxd2_hs_i), 
		.Rx_HS_D_3			((CSI0_BITFLIP[3] ? 8'hFF : 8'h00) ^ csi_rxd3_hs_i), 
		.Rx_HS_D_4			(), 
		.Rx_HS_D_5			(), 
		.Rx_HS_D_6			(), 
		.Rx_HS_D_7			(), 
		
		.Rx_HS_enable_D		({csi_rxd3_hs_en_o, csi_rxd2_hs_en_o, csi_rxd1_hs_en_o, csi_rxd0_hs_en_o}), 
		.LVDS_termen_D		({csi_rxd3_hs_term_en_o, csi_rxd2_hs_term_en_o, csi_rxd1_hs_term_en_o, csi_rxd0_hs_term_en_o}), 
		.fifo_rd_enable		({csi_rxd3_fifo_rd_o, csi_rxd2_fifo_rd_o, csi_rxd1_fifo_rd_o, csi_rxd0_fifo_rd_o}), 
		.fifo_rd_empty		({csi_rxd3_fifo_empty_i, csi_rxd2_fifo_empty_i, csi_rxd1_fifo_empty_i, csi_rxd0_fifo_empty_i}), 
		.DLY_enable_D		(), 
		.DLY_inc_D			(), 
		.u_dly_enable_D		(0), 
		.u_dly_inc_D		(), 
		
		.vsync_vc1			(), 
		.vsync_vc15			(), 
		.vsync_vc12			(), 
		.vsync_vc9			(), 
		.vsync_vc7			(), 
		.vsync_vc14			(), 
		.vsync_vc13			(), 
		.vsync_vc11			(), 
		.vsync_vc10			(), 
		.vsync_vc8			(), 
		.vsync_vc6			(), 
		.vsync_vc4			(), 
		.vsync_vc0			(w_csi_rx_vsync0), 
		.vsync_vc5			(), 
		.vsync_vc3			(), 
		.vsync_vc2			(), 
	
		.irq				(), 
		
		.pixel_data_valid		(w_csi_rx_dvalid), 
		.pixel_data			(w_csi_rx_data), 
		.pixel_per_clk		(), 
		.datatype			(), 
		.shortpkt_data_field	(), 
		.word_count			(), 
		.vcx				(), 
		.vc				(), 
		.hsync_vc3			(), 
		.hsync_vc2			(), 
		.hsync_vc8			(), 
		.hsync_vc12			(), 
		.hsync_vc7			(), 
		.hsync_vc10			(), 
		.hsync_vc1			(), 
		.hsync_vc0			(w_csi_rx_hsync0), 
		.hsync_vc13			(), 
		.hsync_vc4			(), 
		.hsync_vc11			(), 
		.hsync_vc6			(), 
		.hsync_vc9			(), 
		.hsync_vc15			(), 
		.hsync_vc14			(), 
		.hsync_vc5			(), 
		
		.axi_clk			(w_sys_clk), 
		.axi_reset_n		(w_sys_rstn), 
		
		.axi_awaddr			(r_axi_addr), 
		.axi_awvalid		((r_axi_sel == CSI_AXILITE_ID) && r_axi_awvalid), 
		.axi_awready		(w_csi_axi_awready), 
	
		.axi_wvalid			((r_axi_sel == CSI_AXILITE_ID) && r_axi_wvalid), 
		.axi_wdata			(r_axi_wdata), 
		.axi_wready			(w_csi_axi_wready), 
	
		.axi_bvalid			(), 
		.axi_bready			(1), 
		
		.axi_araddr			(r_axi_addr), 
		.axi_arvalid		((r_axi_sel == CSI_AXILITE_ID) && r_axi_arvalid), 
		.axi_arready		(w_csi_axi_arready), 
		
		.axi_rready			(1), 
		.axi_rvalid			(w_csi_axi_rvalid), 
		.axi_rdata			(w_csi_axi_rdata)
		
	);
	
	assign csi_rxd0_rst_o = w_sys_rst; 
	assign csi_rxd1_rst_o = w_sys_rst; 
	assign csi_rxd2_rst_o = w_sys_rst; 
	assign csi_rxd3_rst_o = w_sys_rst; 
`endif
	
	
	
	
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// //	MIPI-CSI Crop
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	// wire			XYCrop_frame_vsync; 
	// wire			XYCrop_frame_href;
	// wire			XYCrop_frame_de;
	// wire	[63:0]	XYCrop_frame_Gray;

	// Sensor_Image_XYCrop
	// #(
	// 	.IMAGE_HSIZE_SOURCE (1280 / CSI_STRB_WIDTH),
	// 	.IMAGE_VSIZE_SOURCE (1024	 ),
	// 	.IMAGE_HSIZE_TARGET (1280 / CSI_STRB_WIDTH),
	// 	.IMAGE_YSIZE_TARGET (720 	 ),
	// 	.PIXEL_DATA_WIDTH	(CSI_DATA_WIDTH) 		//	32		 )
	// )
	// u_Sensor_Image_XYCrop
	// (
	// 	//	globel clock
	// 	.clk			(w_csi_rx_clk),			//	image pixel clock
	// 	.rst_n		(w_sys_rstn),			//	system reset
		
	// //	//CMOS Sensor interface
	// 	.image_in_vsync (w_csi_rx_vsync0		),			//H : Data Valid; L : Frame Sync(Set it by register)
	// 	.image_in_href	(w_csi_rx_hsync0		),			//H : Data vaild, L : Line Sync
	// 	.image_in_de	(w_csi_rx_dvalid		), 			//H : Data Enable, L : Line Sync
	// 	.image_in_data	(w_csi_rx_data),			//8 bits cmos data input
		
	// 	.image_out_vsync(XYCrop_frame_vsync ),			//H : Data Valid; L : Frame Sync(Set it by register)
	// 	.image_out_href (XYCrop_frame_href	),			//H : Data vaild, L : Line Sync
	// 	.image_out_de	(XYCrop_frame_de	), 			//H : Data Enable, L : Line Sync
	// 	.image_out_data (XYCrop_frame_Gray	)			//8 bits cmos data input	
	// );
	
	// reg			r_XYCrop_frame_vsync = 0; 
	// reg			r_XYCrop_frame_href = 0;
	// reg			r_XYCrop_frame_de = 0;
	// reg	[63:0]	r_XYCrop_frame_Gray = 0;
	
	// always @(posedge w_csi_rx_clk) begin
	// 	r_XYCrop_frame_vsync <= XYCrop_frame_vsync; 
	// 	r_XYCrop_frame_href <= XYCrop_frame_href;
	// 	r_XYCrop_frame_de <= XYCrop_frame_de;
	// 	r_XYCrop_frame_Gray <= XYCrop_frame_Gray;
	// end
	
	// 	//Data Write Assignment
	// wire			cmos_frame_vsync = r_XYCrop_frame_vsync;                     //  cmos frame data vsync valid signal
	// wire			cmos_frame_href = r_XYCrop_frame_href && r_XYCrop_frame_de;	 //  cmos frame data href vaild  signal
	// wire	[63:0]	cmos_frame_Gray = r_XYCrop_frame_Gray; 
	
//SIM-------------------------------------------------------------------------------------
	//	No Crop
	wire 			w_sim_fv, w_sim_lv, w_sim_de; 
	reg 	[31:0] 	r_sim_data = 0; 
	wire			cmos_frame_vsync = SIM_DATA ? w_sim_fv : w_csi_rx_vsync0;                     //  cmos frame data vsync valid signal
	wire			cmos_frame_href = SIM_DATA ? w_sim_lv && w_sim_de : w_csi_rx_hsync0 && w_csi_rx_dvalid;	 //  cmos frame data href vaild  signal
	wire	[63:0]	cmos_frame_Gray = SIM_DATA ? r_sim_data : w_csi_rx_data; 
	

	lcd_driver #(
		.V_SYNC(1), .V_BACK(1), .V_TOTAL(1084)
	) u_sim_data (
	    //  global clock
	    .clk        (w_csi_rx_clk   ),
	    .rst_n      (1), 
	    
	    //  lcd interface
	    .lcd_dclk   (               ),
	    .lcd_blank  (               ),
	    .lcd_sync   (               ),
	    .lcd_request(    ), 	//	Request data 1 cycle ahead. 
	    .lcd_hs     (w_sim_lv         ),
	    .lcd_vs     (w_sim_fv         ),
	    .lcd_en     (w_sim_de         ),
	    .lcd_rgb    (),
	    
	    //  user interface
	    .lcd_data   ()
	);

	always @(posedge w_csi_rx_clk) begin
		r_sim_data <= r_sim_data + w_sim_lv && w_sim_de; 
	end
	
	reg 	[1:0] 	r_vsync_i = 0; 
	reg 	[3:0] 	rc_vsync = 0; 
	always @(posedge w_csi_rx_clk) begin
		r_vsync_i <= {r_vsync_i, cmos_frame_vsync}; 
		rc_vsync <= rc_vsync + (r_vsync_i == 2'b01); 
	end
	assign led_o = rc_vsync[3]; 



	
	









	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//	DDR R/W Control
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	wire                            lcd_de;
	wire                            lcd_hs;      
	wire                            lcd_vs;
	wire 					  lcd_request; 
	wire            [7:0]           lcd_red, lcd_red2;
	wire            [7:0]           lcd_green, lcd_green2;
	wire            [7:0]           lcd_blue, lcd_blue2;
	wire            [15:0]          lcd_data;
	
	wire 			w_wframe_vsync; 
	wire 	[7:0] 	w_axi_tp; 
	axi4_ctrl #(.C_RD_END_ADDR(1280 * 720), .C_W_WIDTH(CSI_DATA_WIDTH), .C_R_WIDTH(8), .C_ID_LEN(4)) u_axi4_ctrl (
	//axi4_ctrl #(.C_RD_END_ADDR(1920 * 1080), .C_W_WIDTH(CSI_DATA_WIDTH), .C_R_WIDTH(8), .C_ID_LEN(4)) u_axi4_ctrl (

		.axi_clk        (sys_clk_i       ),
		.axi_reset      (w_hbram_ui_rst       ),

		.axi_awaddr     (w_hbram_awaddr       ),
		.axi_awlen      (w_hbram_awlen        ),
		.axi_awvalid    (w_hbram_awvalid      ),
		.axi_awready    (w_hbram_awready      ),

		.axi_wdata      (w_hbram_wdata        ),
		.axi_wstrb      (w_hbram_wstrb        ),
		.axi_wlast      (w_hbram_wlast        ),
		.axi_wvalid     (w_hbram_wvalid       ),
		.axi_wready     (w_hbram_wready       ),

		.axi_bid        (0          ),
		.axi_bresp      (0        ),
		.axi_bvalid     (1       ),

		.axi_arid       (w_hbram_arid         ),
		.axi_araddr     (w_hbram_araddr       ),
		.axi_arlen      (w_hbram_arlen        ),
		.axi_arvalid    (w_hbram_arvalid      ),
		.axi_arready    (w_hbram_arready      ),

		.axi_rid        (w_hbram_rid          ),
		.axi_rdata      (w_hbram_rdata        ),
		.axi_rresp      (0        ),
		.axi_rlast      (w_hbram_rlast        ),
		.axi_rvalid     (w_hbram_rvalid       ),
		.axi_rready     (w_hbram_rready       ),

		.wframe_pclk    (w_csi_rx_clk          ),
		.wframe_vsync   (cmos_frame_vsync), 	//w_wframe_vsync   ),		//	Writter VSync. Flush on rising edge. Connect to EOF. 
		.wframe_data_en (cmos_frame_href   ),
		.wframe_data    (cmos_frame_Gray),
		
		.rframe_pclk    (w_pixel_clk            ),
		//.rframe_vsync   (lcd_vs             ),		//	Reader VSync. Flush on rising edge. Connect to ~EOF. 
		.rframe_vsync   (lcd_vs             ),		//	Reader VSync. Flush on rising edge. Connect to ~EOF.
		.rframe_data_en (lcd_request             ),
		.rframe_data    (lcd_data           ),
		
		.tp_o 		(w_axi_tp)
	);
	assign w_hbram_awid = 0; 
	assign w_hbram_wid = 0; 
	
	
	
	////////////////////////////////////////////////////////////////
	//  LCD Timing Driver
	lcd_driver u_lcd_driver
	(
	    //  global clock
	    .clk        (w_pixel_clk   ),
	    .rst_n      (w_pixel_rstn), 
	    
	    //  lcd interface
	    .lcd_dclk   (               ),
	    .lcd_blank  (               ),
	    .lcd_sync   (               ),
	    .lcd_request(lcd_request    ), 	//	Request data 1 cycle ahead. 
	    .lcd_hs     (lcd_hs         ),
	    .lcd_vs     (lcd_vs         ),
	    .lcd_en     (lcd_de         ),
	    .lcd_rgb    ({lcd_red2,lcd_green2,lcd_blue2, lcd_red,lcd_green,lcd_blue}),
	    
	    //  user interface
	    .lcd_data   ({{3{lcd_data[15:8]}}, {3{lcd_data[7:0]}}}  )
	);
	
	
	
	
	wire 			w_rgb_vsync, w_rgb_href; 
	wire 	[7:0] 	w_rgb_r, w_rgb_g, w_rgb_b; 
	
	// VIP_RAW8_RGB888 #(.IMG_HDISP(1920), .IMG_VDISP(1080)) bayer2rgb (
	// 	.clk				(w_pixel_clk),  	//cmos video pixel clock
	// 	.rst_n			(w_pixel_rstn), 	//global reset
	    
	// 	.mirror			(2'b00),
		
	// 	    //CMOS YCbCr444 data output
	// 	.per_frame_vsync		(lcd_vs),    	//	Prepared Image data vsync valid signal. Reset on falling edge. 
	// 	.per_frame_href		(lcd_de),     	//	Prepared Image data href vaild  signal
	// 	.per_frame_hsync    	(lcd_hs), 
	// 	.per_img_RAW		(lcd_data[7:0]), 	//	Input data from AXI reader directly. Latency is 1T. Matches with VS / HS / DE signals. 
		
	// 	.post_frame_vsync		(w_rgb_vsync),   	//Processed Image data vsync valid signal
	// 	.post_frame_href		(w_rgb_href),    	//Processed Image data href vaild  signal
	// 	.post_frame_hsync		(w_rgb_hsync),    //Processed Image data href vaild  signal
	// 	.post_img_red		(w_rgb_r),       	//Prepared Image green data to be processed 
	// 	.post_img_green		(w_rgb_g),     	//Prepared Image green data to be processed
	// 	.post_img_blue		(w_rgb_b)      	//Prepared Image blue data to be processed
	// );
	
	
	// wire 			w_rgb_vs_o, w_rgb_hs_o, w_rgb_de_o; 
	// wire 	[23:0] 	w_rgb_data_o; 
	// FrameBoundCrop rgb_crop (
	// 	.clk_i			(w_pixel_clk),
	// 	.rst_i			(w_pixel_rst),
		
	// 	.vs_i 			(w_rgb_vsync),
	// 	.hs_i 			(w_rgb_hsync),
	// 	.de_i 			(w_rgb_href),
	// 	.data_i			({w_rgb_r, w_rgb_g, w_rgb_b}),
		
	// 	.vs_o 			(w_rgb_vs_o),
	// 	.hs_o 			(w_rgb_hs_o),
	// 	.de_o 			(w_rgb_de_o),
	// 	.data_o			(w_rgb_data_o)
	// );

	
	
	
	////////////////////////////////////////////////////////////////
	//	HDMI Interface. 
	assign hdmi_txd0_rst_o = w_pixel_rst; 
	assign hdmi_txd1_rst_o = w_pixel_rst; 
	assign hdmi_txd2_rst_o = w_pixel_rst; 
	assign hdmi_txc_rst_o = w_pixel_rst; 
	
	assign hdmi_txd0_oe = 1'b1; 
	assign hdmi_txd1_oe = 1'b1; 
	assign hdmi_txd2_oe = 1'b1; 
	assign hdmi_txc_oe = 1'b1; 
	
	// //-------------------------------------
	// //Digilent HDMI-TX IP Modified by CB elec.
	// rgb2dvi #(.ENABLE_OSERDES(0)) u_rgb2dvi 
	// (
	// 	.oe_i 		(1), 			//	Always enable output
	// 	.bitflip_i 		(HDMI_BITFLIP), 	//	Reverse clock & data lanes. 
		
	// 	.aRst			(w_pixel_rst), 
	// 	.aRst_n		(w_pixel_rstn), 
		
	// 	.PixelClk		(w_pixel_clk        ),
	// 	.SerialClk		(),
		
	// 	.vid_pVSync		(w_rgb_vs_o), 
	// 	.vid_pHSync		(w_rgb_hs_o), 
	// 	.vid_pVDE		(w_rgb_de_o), 
	// 	.vid_pData		(w_rgb_data_o), 
		
	// 	.txc_o		(hdmi_txc_o), 
	// 	.txd0_o		(hdmi_txd0_o), 
	// 	.txd1_o		(hdmi_txd1_o), de
	// 	.txd2_o		(hdmi_txd2_o)
	// ); 
		//-------------------------------------
	//Digilent HDMI-TX IP Modified by CB elec.
	//wire [7:0] Post_Data;
    //Curve_Gamma_2P2 u_Curve_Gamma_2P2
    //(
    //   .Pre_Data  (lcd_data[7:0]),
    //   .Post_Data (Post_Data)
    //);
	wire [7:0] alg_data;
	wire alg_vs,alg_hs,alg_de;
    //region_bin_auto_proc
    //#(
    //    .IMG_HDISP(1080),            //  640*480
    //    .IMG_VDISP(720)
    //)u_region_bin_auto_proc
    //(
    //    .clk  (w_pixel_clk)           ,
    //    .rst_n(w_pixel_rstn)           ,
    //    
    //    //  Image data prepared to be processed
    //    .per_img_vsync(lcd_vs)   ,       //  Prepared Image data vsync valid signal
    //    .per_img_href (lcd_hs)   ,       //  Prepared Image data href vaild  signal
    //    .per_img_gray (lcd_data[7:0])   ,       //  Prepared Image brightness input
    //    .per_de(lcd_de),
    //    //  Image data has been processed
	//	.post_de(alg_de),
    //    .post_img_vsync(alg_vs)  ,       //  processed Image data vsync valid signal
    //    .post_img_href (alg_hs)  ,       //  processed Image data href vaild  signal
    //    .post_img_gray (alg_data)          //  processed Image brightness output
    //);

	wire                i_clk; 	
	wire                i_rst_n; 	
	wire				o_gray_hsyn;
	wire				o_gray_vsyn;
	wire	[23:0]		o_gray_data;
	wire				o_gray_de;
						
	wire				o_hsyn_b;	
	wire				o_vsyn_b;	
	wire [7:0]			o_r_b;
	wire [7:0] 			o_g_b;
	wire [7:0] 			o_b_b;	
	wire				o_en_b;
	

//image_gaussian_filtering u_image_gaussian_filtering
//(
//	.i_clk			(w_pixel_clk				),
//	.i_rst_n		(w_pixel_rstn			),
//	.i_hsyn		    (lcd_hs				),
//	.i_vsyn		    (lcd_vs				),
//	.i_en		    (lcd_de				),
//	.i_r		    (lcd_data[7:0]				),
//	.i_g		    (lcd_data[7:0]				),
//	.i_b		    (lcd_data[7:0]			),		
//	.o_hs		    (o_hsyn_b		),
//	.o_vs		    (o_vsyn_b		),
//	.o_en		    (o_en_b			),	
//	.o_r		    (o_r_b	),
//	.o_g		    (o_g_b),
//	.o_b		    (o_b_b	)	
//);

	image_sobel_filtering u_image_sobel_filtering
	(
	.i_clk			(w_pixel_clk			),
	.i_rst_n		(w_pixel_rstn			),
	.i_hsyn		    (lcd_hs			),
	.i_vsyn		    (lcd_vs			),
	.i_en		    (lcd_de			),
	.i_r		    (lcd_data[7:0] ),
	.i_g		    (lcd_data[7:0] ),
	.i_b		    (lcd_data[7:0] ),	
	.threshold		(300			),
	.o_hs		    (o_gray_hsyn		),
	.o_vs		    (o_gray_vsyn		),
	.o_en		    (o_gray_de			),	
	.o_r		    (o_gray_data[23:16]	),
	.o_g		    (o_gray_data[15:8]	),
	.o_b		    (o_gray_data[7:0]	)	
	);
	  
	wire    o_hsyn;
	wire    o_vsyn;
	wire    o_de;
	wire [7:0]   o_data;
	


  
    wire          per_frame_vsync;
    wire          per_frame_href;
    wire          per_frame_clken;
    wire          per_img_Bit;
  
    wire          post_frame_vsync_a;
    wire          post_frame_href_a;
    wire          post_frame_clken_a;
    wire          post_img_Bit_a;
    wire  [10:0]  x_max_1;
    wire  [10:0]  x_max_2;
    wire  [15:0]  y_max_1;
    wire  [15:0]  y_max_2;
	wire  o_hsyn	   ;
	wire  o_vsyn	   ;
	wire  o_de	       ;
	wire [7:0] o_data       ;
	wire   dilate_hsyn     ;
	wire   dilate_vsyn     ;
	wire   dilate_de	   ;
	wire  [7:0] dilate_data     ;

	
//   binarization u_binarization
//   (
//    .clk               (w_pixel_clk)   ,
//    .rst_n             (w_pixel_rstn)   ,
//   
//    .gray_vsync        (lcd_vs)   ,
//    .gray_hsync        (lcd_hs)   ,
//    .gray_data_valid   (lcd_de)   ,// 数据有效信号
//    .gray_data_in    (lcd_data[7:0]),
//   
//    .binary_vsync      (alg_vs)   ,
//    .binary_hsync      (alg_hs)   ,
//    .binary_data_valid (alg_de)   ,// 数据有效信号
//    .binary_data_out   (alg_data)
//    );
	 tops(
.i_clk		(w_pixel_clk)	,
.i_rst		(w_pixel_rst)	,
.i_I0		(lcd_data[7:0])	,
.o_Ifilter	(alg_data)	,
.o_Ifilter2 ()
);

						
	wire				o_hsyn_b;	
	wire				o_vsyn_b;	
	wire [7:0]			o_r_b;
	wire [7:0] 			o_g_b;
	wire [7:0] 			o_b_b;	
	wire				o_en_b;
	

image_gaussian_filtering u_image_gaussian_filtering
(
	.i_clk			(w_pixel_clk				),
	.i_rst_n		(w_pixel_rstn			),
	.i_hsyn		    (o_gray_hsyn				),
	.i_vsyn		    (o_gray_vsyn				),		
	.i_en		    (o_gray_de				),      
	.i_r		    (o_gray_data[7:0]				),  	
	.i_g		    (o_gray_data[7:0]				),  
	.i_b		    (o_gray_data[7:0]			),		
	.o_hs		    (o_hsyn_b		),
	.o_vs		    (o_vsyn_b		),
	.o_en		    (o_en_b			),	
	.o_r		    (o_r_b	),
	.o_g		    (),
	.o_b		    ()	
);

	wire				o_gray_hsyn_a;
	wire				o_gray_vsyn_a;
	wire	[7:0]		o_gray_data_a;
	wire				o_gray_de_a;

 image_open_filtering u_image_open_filtering
(
	.clk_i			(w_pixel_clk				),
	.a_rst_i		(w_pixel_rstn			),
	.i_hsyn		    (o_hsyn_b			),
	.i_vsyn		    (o_vsyn_b			),
	.i_en		    (o_en_b			),
	.i_binary		(o_r_b				),
	.o_hs		    (o_gray_hsyn_a				),
	.o_vs		    (o_gray_vsyn_a				),
	.o_en		    (o_gray_de_a				),	
	.o_binary		(o_gray_data_a			)
);


    // 实例化 module touying
    touying #(
        .IMG_HDISP(11'd1280),   // 参数 IMG_HDISP，设置为 1280
        .IMG_VDISP(11'd720)     // 参数 IMG_VDISP，设置为 720
    ) u_touying (
        .clk(w_pixel_clk),                    // 时钟信号
        .rst_n(w_pixel_rstn),                // 复位信号
        
        // 输入信号
        .per_frame_vsync(o_gray_vsyn_a),
        .per_frame_href(o_gray_hsyn_a),		
        .per_frame_clken(o_gray_de_a),      
        .per_img_Bit(o_gray_data_a[0]),     
                                            
        // 输出信号
        .post_frame_vsync(),
        .post_frame_href(),
        .post_frame_clken(),
        .post_img_Bit(),
        .x_max_1(x_max_1),
        .x_max_2(x_max_2),
        .y_max_1(y_max_1),
        .y_max_2(y_max_2),
		.coords_valid  (coords_valid)
    );
	wire [10:0] x_max_1_a ;
	wire [10:0] x_max_2_a ;
	wire [15:0] y_max_1_a ;
	wire [15:0] y_max_2_a ;


touying_tongkong
#(
.IMG_HDISP (11'd1280),   
.IMG_VDISP (11'd720),
.BOX_WIDTH  (10'd100),   
.BOX_HEIGHT (10'd100)  
)u_touying_tongkong
(
.clk				(w_pixel_clk)	,                  
.rst_n				(w_pixel_rstn)	,                       
.per_frame_vsync	(lcd_vs)	,     
.per_frame_href		(lcd_hs)	,      
.per_frame_clken	(lcd_de)	,     
.per_img_Bit		(alg_data[0]),                 
.post_frame_vsync	()		,    		
.post_frame_href	()	,               
.post_frame_clken	()	,               
.post_img_Bit		()	,               
.max_x_1			(x_max_1)	,               
.y_avg_1			(y_max_1)	,               
.max_x_2			(x_max_2)	,               
.y_avg_2			(y_max_2)	,                 
.coords_valid		(coords_valid)	,
.x_max_1			(x_max_1_a)	,
.x_max_2			(x_max_2_a)	,
.y_max_1			(y_max_1_a)	,
.y_max_2            (y_max_2_a)
);

	





	wire   coords_valid;
	wire   post_frame_vsync;
	wire   post_frame_href;
	wire   post_frame_clken;
	wire   [23:0]    post_img_Bit;
	wire   o_vsyn_a;
	wire   o_hsyn_a;
	wire   o_en_a;			
	wire [23:0]   o_data_a; 	
	wire [23:0]   o_data_b;
	wire   o_vsyn_c;
	wire   o_hsyn_c;
	wire   o_en_c;	
	
	

//image_gaussian_filtering u_image_gaussian_filtering_a
//(
//	.i_clk			(w_pixel_clk				),
//	.i_rst_n		(w_pixel_rstn			),
//	.i_hsyn		    (lcd_hs				),
//	.i_vsyn		    (lcd_vs				),		
//	.i_en		    (lcd_de				),      
//	.i_r		    (lcd_data[7:0]				),  	
//	.i_g		    (lcd_data[7:0]				),  
//	.i_b		    (lcd_data[7:0]			),		
//	.o_hs		    (o_hsyn_a		),
//	.o_vs		    (o_vsyn_a		),
//	.o_en		    (o_en_a			),	
//	.o_r		    (o_data_a[7:0]	),
//	.o_g		    (o_data_a[15:8]),
//	.o_b		    (o_data_a[23:16])	
//);
//image_gaussian_filtering u_image_gaussian_filtering_b
//(
//	.i_clk			(w_pixel_clk				),
//	.i_rst_n		(w_pixel_rstn			),
//	.i_hsyn		    (o_hsyn_a				),
//	.i_vsyn		    (o_vsyn_a				),		
//	.i_en		    (o_en_a				),      
//	.i_r		    (o_data_a[7:0]				),  	
//	.i_g		    (o_data_a[7:0]				),  
//	.i_b		    (o_data_a[7:0]			),		
//	.o_hs		    (o_hsyn_c		),
//	.o_vs		    (o_vsync		),
//	.o_en		    (o_en_c		),	
//	.o_r		    (o_data_b[7:0]	),
//	.o_g		    (o_data_b[15:8]),
//	.o_b		    (o_data_b[23:16])	
//);
huakuang #(
       .IMG_HDISP(11'd1280),              // 图像宽度
       .IMG_VDISP(11'd720),               // 图像高度
       .BOX_WIDTH(10'd100),               // 边框宽度
       .BOX_HEIGHT(10'd100),              // 边框高度
       .BORDER_THICKNESS(4'd2)            // 边框厚度
   ) u_huakuang (
       .clk(w_pixel_clk),
       .rst_n(w_pixel_rstn),
       .per_frame_clken(lcd_de),			
       .per_frame_vsync(lcd_vs),             
       .per_frame_href(lcd_hs),              
       .max_x_1(x_max_1_a),    									
       .y_avg_1(y_max_1_a),                  
       .max_x_2(x_max_2_a),
       .y_avg_2(y_max_2_a),
       .per_img_Bit({lcd_data[7:0],lcd_data[7:0],lcd_data[7:0]}),
       .post_frame_vsync(post_frame_vsync),
       .post_frame_href(post_frame_href),
       .post_frame_clken(post_frame_clken),
       .post_img_Bit(post_img_Bit)
   );




rgb2dvi #(.ENABLE_OSERDES(0)) u_rgb2dvi 
	(
		.oe_i 		(1), 			//	Always enable output
		.bitflip_i 		(HDMI_BITFLIP), 	//	Reverse clock & data lanes. 
		
		.aRst			(w_pixel_rst), 
		.aRst_n		(w_pixel_rstn), 
		
		.PixelClk		(w_pixel_clk        ),
		.SerialClk		(),
		
		.vid_pVSync		(post_frame_vsync), 										
		.vid_pHSync		(post_frame_href),                                 
		.vid_pVDE		(post_frame_clken),                                   
		.vid_pData		(post_img_Bit),  	
		                                                          
		.txc_o		(hdmi_txc_o),       
		.txd0_o		(hdmi_txd0_o), 
		.txd1_o		(hdmi_txd1_o), 
		.txd2_o		(hdmi_txd2_o)
	); 
	
endmodule


