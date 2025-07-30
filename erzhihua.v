module binarization(
    input clk,
    input rst_n,

    // 图像处理前的数据接口
    input gray_vsync,
    input gray_hsync,
    input gray_data_valid, // 数据有效信号
    input [7:0] gray_data_in, 

    // 图像处理后的数据接口
    output reg binary_vsync,
    output reg binary_hsync,
    output reg binary_data_valid, // 数据有效信号
    output reg [7:0] binary_data_out 
);

    // 参数定义：二值化阈值
    parameter THRESHOLD = 8'd20; 

    // 寄存器定义：用于存储二值化结果
    reg monoc;

    // 二值化处理：比较灰度值与阈值，确定像素是前景还是背景
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            monoc <= 1'b0;
        end else begin
            monoc <= (gray_data_in > THRESHOLD) ? 1'b1 : 1'b0;
        end
    end

    // 同步信号和数据输出：传递同步信号和数据有效信号，更新二值化图像数据
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            binary_vsync      <= 1'b0;
            binary_hsync      <= 1'b0;
            binary_data_valid <= 1'b0;
            binary_data_out   <= 8'd0;
        end else begin
            binary_vsync      <= gray_vsync;
            binary_hsync      <= gray_hsync;
            binary_data_valid <= gray_data_valid;
            binary_data_out   <= monoc ? 8'hFF : 8'h00;
        end
    end

endmodule