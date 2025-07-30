`timescale 1ns / 1ps
module image_gaussian_filtering
(
    input   wire                i_clk,
    input   wire                i_rst_n,

    input   wire                i_hsyn,
    input   wire                i_vsyn,
    input   wire                i_en,
    input   wire [7:0]          i_r,
    input   wire [7:0]          i_g,
    input   wire [7:0]          i_b,		// 输入RGB分量
	
    output  wire                o_hs,
    output  wire                o_vs,
    output  wire                o_en,	
    output  wire [7:0]          o_r,
    output  wire [7:0]          o_g,
    output  wire [7:0]          o_b  	// 输出RGB分量
);

// 同步信号的寄存器延迟
reg	[3:0]		i_hsyn_d;
reg	[3:0]		i_vsyn_d;
reg	[3:0]		i_en_d;

// 高斯滤波累加器
reg [11:0]		sum_r;
reg [11:0]		sum_g;
reg [11:0]		sum_b;

// 高斯滤波中间累加器
reg [11:0]		sum_r1;
reg [11:0]		sum_g1;
reg [11:0]		sum_b1;

reg [11:0]		sum_r2;
reg [11:0]		sum_g2;
reg [11:0]		sum_b2;

reg [11:0]		sum_r3;
reg [11:0]		sum_g3;
reg [11:0]		sum_b3;

// 高斯滤波后的RGB分量
reg [7:0]		gau_r;
reg [7:0]		gau_g;
reg [7:0]		gau_b;

// image_template模块的输出，用于存储3x3邻域的RGB分量
wire [7:0]	r_temp_11;
wire [7:0]	r_temp_12;
wire [7:0]	r_temp_13;
wire [7:0]	r_temp_21;
wire [7:0]	r_temp_22;
wire [7:0]	r_temp_23;
wire [7:0]	r_temp_31;
wire [7:0]	r_temp_32;
wire [7:0]	r_temp_33;

wire [7:0]	g_temp_11;
wire [7:0]	g_temp_12;
wire [7:0]	g_temp_13;
wire [7:0]	g_temp_21;
wire [7:0]	g_temp_22;
wire [7:0]	g_temp_23;
wire [7:0]	g_temp_31;
wire [7:0]	g_temp_32;
wire [7:0]	g_temp_33;

wire [7:0]	b_temp_11;
wire [7:0]	b_temp_12;
wire [7:0]	b_temp_13;
wire [7:0]	b_temp_21;
wire [7:0]	b_temp_22;
wire [7:0]	b_temp_23;
wire [7:0]	b_temp_31;
wire [7:0]	b_temp_32;
wire [7:0]	b_temp_33;

// 将延迟寄存器的输出连接到模块输出
assign o_hs = i_hsyn_d[3];
assign o_vs = i_vsyn_d[3];
assign o_en = i_en_d[3];
assign o_r = gau_r;
assign o_g = gau_g;
assign o_b = gau_b;

// 同步信号的延迟处理
always@(posedge i_clk ) 
begin
    i_hsyn_d <=	{i_hsyn_d[2:0],i_hsyn};
    i_vsyn_d <=	{i_vsyn_d[2:0],i_vsyn};
    i_en_d	 <=	{i_en_d[2:0],i_en};
end

// 实例化R分量的image_template模块
image_template u_r_template
(
    .i_clk         (i_clk                ),
    .i_rst_n       (i_rst_n              ),
    .i_en          (i_en                 ),
    .i_data        (i_r                  ),
    .o_en          (                      ),
    .o_temp_11     (r_temp_11            ),
    .o_temp_12     (r_temp_12            ),
    .o_temp_13     (r_temp_13            ),
    .o_temp_21     (r_temp_21            ),
    .o_temp_22     (r_temp_22            ),
    .o_temp_23     (r_temp_23            ),
    .o_temp_31     (r_temp_31            ),
    .o_temp_32     (r_temp_32            ),
    .o_temp_33     (r_temp_33            )
);

// 实例化G分量的image_template模块
image_template u_g_template
(
    .i_clk         (i_clk                ),
    .i_rst_n       (i_rst_n              ),
    .i_en          (i_en                 ),
    .i_data        (i_g                  ),
    .o_en          (                      ),
    .o_temp_11     (g_temp_11            ),
    .o_temp_12     (g_temp_12            ),
    .o_temp_13     (g_temp_13            ),
    .o_temp_21     (g_temp_21            ),
    .o_temp_22     (g_temp_22            ),
    .o_temp_23     (g_temp_23            ),
    .o_temp_31     (g_temp_31            ),
    .o_temp_32     (g_temp_32            ),
    .o_temp_33     (g_temp_33            )
);

// 实例化B分量的image_template模块
image_template u_b_template
(
    .i_clk         (i_clk                ),
    .i_rst_n       (i_rst_n              ),
    .i_en          (i_en                 ),
    .i_data        (i_b                  ),
    .o_en          (                      ),
    .o_temp_11     (b_temp_11            ),
    .o_temp_12     (b_temp_12            ),
    .o_temp_13     (b_temp_13            ),
    .o_temp_21     (b_temp_21            ),
    .o_temp_22     (b_temp_22            ),
    .o_temp_23     (b_temp_23            ),
    .o_temp_31     (b_temp_31            ),
    .o_temp_32     (b_temp_32            ),
    .o_temp_33     (b_temp_33            )
);

// 高斯滤波计算
always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n) 
    begin
        sum_r1 <= 12'd0;
        sum_g1 <= 12'd0;
        sum_b1 <= 12'd0;
        sum_r2 <= 12'd0;
        sum_g2 <= 12'd0;
        sum_b2 <= 12'd0;
        sum_r3 <= 12'd0;
        sum_g3 <= 12'd0;
        sum_b3 <= 12'd0;
    end
    else 
    begin
        sum_r1 <= r_temp_11 + r_temp_12 + r_temp_13;
        sum_r2 <= r_temp_21 + r_temp_22*8 + r_temp_23;
        sum_r3 <= r_temp_31 + r_temp_32 + r_temp_33;
        
        sum_g1 <= g_temp_11 + g_temp_12 + g_temp_13;
        sum_g2 <= g_temp_21 + g_temp_22*8 + g_temp_23;
        sum_g3 <= g_temp_31 + g_temp_32 + g_temp_33;
        
        sum_b1 <= b_temp_11 + b_temp_12 + b_temp_13;
        sum_b2 <= b_temp_21 + b_temp_22*8 + b_temp_23;
        sum_b3 <= b_temp_31 + b_temp_32 + b_temp_33;
    end
end

always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n) 
    begin
        sum_r <= 12'd0;
        sum_g <= 12'd0;
        sum_b <= 12'd0;
    end
    else 
    begin
        sum_r <= sum_r1 + sum_r2 + sum_r3;
		sum_g <= sum_g1 + sum_g2 + sum_g3;
		sum_b <= sum_b1 + sum_b2 + sum_b3;
    end
end

always@(posedge i_clk or negedge i_rst_n) 
begin
    if(!i_rst_n) 
	begin
        gau_r <= 8'd0;
        gau_g <= 8'd0;
        gau_b <= 8'd0;
    end
    else 
	begin
        gau_r <= sum_r >> 4;
		gau_g <= sum_g >> 4;
		gau_b <= sum_b >> 4;
    end
end


endmodule