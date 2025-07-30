`timescale 1ns / 1ps
module image_erode_filtering
(
    input   wire                clk_i,        // 输入时钟信号
    input   wire                a_rst_i,      // 复位信号，低电平有效
    input   wire                i_hsyn,       // 输入水平同步信号
    input   wire                i_vsyn,       // 输入垂直同步信号
    input   wire                i_en,         // 输入使能信号
    input   wire [7:0]          i_binary,     // 输入的二值化图像数据，8位宽
    
    output  wire                o_hs,         // 输出的水平同步信号
    output  wire                o_vs,         // 输出的垂直同步信号
    output  wire                o_en,         // 输出的使能信号    
    output  wire [7:0]          o_binary      // 输出的腐蚀后的二值化图像数据
);

// 延迟寄存器，用于同步信号的三拍延迟
reg [2:0] i_hsyn_d;
reg [2:0] i_vsyn_d;
reg [2:0] i_en_d;

// 腐蚀操作的中间变量
reg erode_and;
reg [7:0] binary_reg;

// 3x3邻域的像素值
wire [7:0] r_temp_11;
wire [7:0] r_temp_12;
wire [7:0] r_temp_13;
wire [7:0] r_temp_21;
wire [7:0] r_temp_22;
wire [7:0] r_temp_23;
wire [7:0] r_temp_31;
wire [7:0] r_temp_32;
wire [7:0] r_temp_33;

// 将同步信号和使能信号延迟三拍
always@(posedge clk_i) 
begin
    i_hsyn_d <= {i_hsyn_d[1:0], i_hsyn};
    i_vsyn_d <= {i_vsyn_d[1:0], i_vsyn};
    i_en_d   <= {i_en_d[1:0], i_en};
end

// 实例化image_template模块，用于提取3x3邻域的像素值
image_template u_r_template
(
    .i_clk        (clk_i),
    .i_rst_n      (a_rst_i),
    .i_en         (i_en),
    .i_data       (i_binary),
    .o_en         (),
    .o_temp_11    (r_temp_11),
    .o_temp_12    (r_temp_12),
    .o_temp_13    (r_temp_13),  
    .o_temp_21    (r_temp_21),
    .o_temp_22    (r_temp_22),
    .o_temp_23    (r_temp_23),      
    .o_temp_31    (r_temp_31),
    .o_temp_32    (r_temp_32),
    .o_temp_33    (r_temp_33)
);

// 腐蚀操作逻辑
always@(posedge clk_i or negedge a_rst_i) 
begin
    if(!a_rst_i) 
    begin
        erode_and <= 1'b0;
    end
    else 
    begin
        // 只有当3x3邻域内所有像素都是1时，erode_and才为1
        erode_and <= r_temp_11[0] & 
                     r_temp_12[0] & 
                     r_temp_13[0] & 
                     r_temp_21[0] & 
                     r_temp_22[0] & 
                     r_temp_23[0] & 
                     r_temp_31[0] & 
                     r_temp_32[0] & 
                     r_temp_33[0];
    end
end

// 更新输出的二值化图像数据
always@(posedge clk_i or negedge a_rst_i) 
begin
    if(!a_rst_i) 
    begin
        binary_reg <= 8'd0;
    end
    else if(erode_and)
    begin
        binary_reg <= 8'd255;
    end
    else 
    begin
        binary_reg <= 8'd0;
    end
end

// 将处理后的信号输出
assign o_hs = i_hsyn_d[2];
assign o_vs = i_vsyn_d[2];
assign o_en = i_en_d[2];
assign o_binary = binary_reg;

endmodule