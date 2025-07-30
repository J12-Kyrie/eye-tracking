`timescale 1ns / 1ps
module image_dilate_filtering
(
    input   wire                clk_i,          // 输入时钟信号
    input   wire                a_rst_i,        // 复位信号，低电平有效

    input   wire                i_hsyn,         // 输入的水平同步信号
    input   wire                i_vsyn,         // 输入的垂直同步信号
    input   wire                i_en,           // 输入使能信号
    input   wire [7:0]          i_binary,       // 输入的二值化图像数据

    output  wire                o_hs,           // 输出的水平同步信号
    output  wire                o_vs,           // 输出的垂直同步信号
    output  wire                o_en,           // 输出使能信号
    output  wire [7:0]          o_binary        // 输出的膨胀后二值化图像数据
);

// 延迟寄存器，用于同步信号的三拍延迟
reg [2:0] i_hsyn_d;
reg [2:0] i_vsyn_d;
reg [2:0] i_en_d;

// 膨胀操作的中间寄存器
reg        dilate_or;
reg  [7:0] binary_reg;

// image_template模块的输出，用于存储3x3邻域的像素值
wire [7:0] r_temp_11;
wire [7:0] r_temp_12;
wire [7:0] r_temp_13;
wire [7:0] r_temp_21;
wire [7:0] r_temp_22;
wire [7:0] r_temp_23;
wire [7:0] r_temp_31;
wire [7:0] r_temp_32;
wire [7:0] r_temp_33;

// 将延迟寄存器的输出连接到模块输出
assign o_hs  = i_hsyn_d[2];
assign o_vs  = i_vsyn_d[2];
assign o_en  = i_en_d[2];
assign o_binary = binary_reg;

// 水平同步、垂直同步和使能信号的延迟处理
always @(posedge clk_i) 
begin
    i_hsyn_d <= {i_hsyn_d[1:0], i_hsyn};
    i_vsyn_d <= {i_vsyn_d[1:0], i_vsyn};
    i_en_d   <= {i_en_d[1:0], i_en};
end

// 实例化image_template模块，用于提取3x3邻域的像素值
image_template u_r_template
(
    .i_clk         (clk_i),
    .i_rst_n       (a_rst_i),
    .i_en          (i_en),
    .i_data        (i_binary),
    .o_en          (),
    .o_temp_11     (r_temp_11),
    .o_temp_12     (r_temp_12),
    .o_temp_13     (r_temp_13),
    .o_temp_21     (r_temp_21),
    .o_temp_22     (r_temp_22),
    .o_temp_23     (r_temp_23),
    .o_temp_31     (r_temp_31),
    .o_temp_32     (r_temp_32),
    .o_temp_33     (r_temp_33)
);

// 膨胀操作逻辑
always @(posedge clk_i or negedge a_rst_i) 
begin
    if (!a_rst_i)
    begin
        dilate_or <= 1'b0;
    end
    else 
    begin
        // 如果3x3邻域内任意像素为1，则dilate_or为1
        dilate_or <= r_temp_11[0] ||
                      r_temp_12[0] ||
                      r_temp_13[0] ||
                      r_temp_21[0] ||
                      r_temp_22[0] ||
                      r_temp_23[0] ||
                      r_temp_31[0] ||
                      r_temp_32[0] ||
                      r_temp_33[0];
    end
end

// 二值化图像数据输出逻辑
always @(posedge clk_i or negedge a_rst_i) 
begin
    if (!a_rst_i)
    begin
        binary_reg <= 8'd0;
    end
    else if (dilate_or)
    begin
        // 如果dilate_or为1，则输出255（白色）
        binary_reg <= 8'd255;
    end
    else 
    begin
        // 否则输出0（黑色）
        binary_reg <= 8'd0;
    end
end

endmodule