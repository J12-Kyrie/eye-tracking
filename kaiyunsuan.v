`timescale 1ns / 1ps
module image_open_filtering
(
    input   wire                clk_i,
    input   wire                a_rst_i,

    input   wire                i_hsyn,
    input   wire                i_vsyn,
    input   wire                i_en,
    input   wire [7:0]          i_binary,

    output  wire                o_hs,
    output  wire                o_vs,
    output  wire                o_en,
    output  wire [7:0]          o_binary
);

// 连接腐蚀模块的输出和膨胀模块的输入
wire                        erode_hsyn;
wire                        erode_vsyn;
wire                        erode_de;
wire [7:0]                  erode_data;

wire                        dilate_hsyn;
wire                        dilate_vsyn;
wire                        dilate_de;
wire [7:0]                  dilate_data;

// 将腐蚀模块的输出连接到开运算模块的输出
assign o_hs     = dilate_hsyn;
assign o_vs     = dilate_vsyn;
assign o_en     = dilate_de;
assign o_binary = dilate_data;

// 实例化腐蚀模块
image_erode_filtering u_image_erode_filtering
(
    .clk_i        (clk_i                ),
    .a_rst_i      (a_rst_i              ),
    .i_hsyn       (i_hsyn               ),
    .i_vsyn       (i_vsyn               ),
    .i_en         (i_en                 ),
    .i_binary     (i_binary             ),
    .o_hs         (erode_hsyn           ),
    .o_vs         (erode_vsyn           ),
    .o_en         (erode_de             ),
    .o_binary     (erode_data           )
);

// 实例化膨胀模块
image_dilate_filtering u_image_dilate_filtering
(
    .clk_i        (clk_i                ),
    .a_rst_i      (a_rst_i              ),
    .i_hsyn       (erode_hsyn           ),
    .i_vsyn       (erode_vsyn           ),
    .i_en         (erode_de             ),
    .i_binary     (erode_data           ),
    .o_hs         (dilate_hsyn          ),
    .o_vs         (dilate_vsyn          ),
    .o_en         (dilate_de            ),
    .o_binary     (dilate_data          )
);

endmodule