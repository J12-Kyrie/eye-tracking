module touying
#(
    parameter   [10:0]  IMG_HDISP = 11'd1280,   
    parameter   [10:0]  IMG_VDISP = 11'd720
)
(
    input                clk,                  
    input                rst_n,               
                                
    // 输入信号                     
    input                per_frame_vsync,     
    input                per_frame_href,      
    input                per_frame_clken,     
    input                per_img_Bit,         
                                
    // 输出信号                     
    output               post_frame_vsync,    
    output               post_frame_href,     
    output               post_frame_clken,    
    output               post_img_Bit,        
    output   reg [10:0]  x_max_1,
    output   reg [10:0]  x_max_2,
    output   reg [15:0]  y_max_1,
    output   reg [15:0]  y_max_2,
    output               coords_valid         // Coordinates validity signal
);

reg  per_frame_vsync_r, per_frame_href_r, per_frame_clken_r, per_img_Bit_r;
reg  per_frame_vsync_r2, per_frame_href_r2, per_frame_clken_r2, per_img_Bit_r2;

assign post_frame_vsync  = per_frame_vsync_r2;
assign post_frame_href   = per_frame_href_r2;  
assign post_frame_clken  = per_frame_clken_r2;
assign post_img_Bit      = per_img_Bit_r2;

//------------------- 打拍 ---------------------
always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        per_frame_vsync_r2 <= 0;
        per_frame_href_r2  <= 0;
        per_frame_clken_r2 <= 0;
        per_img_Bit_r2     <= 0;
    end else begin
        per_frame_vsync_r2 <= per_frame_vsync_r;
        per_frame_href_r2  <= per_frame_href_r;
        per_frame_clken_r2 <= per_frame_clken_r;
        per_img_Bit_r2     <= per_img_Bit_r;
    end
end

//------------------------------------------

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        per_frame_vsync_r <= 0;
        per_frame_href_r  <= 0;
        per_frame_clken_r <= 0;
        per_img_Bit_r     <= 0;
    end else begin
        per_frame_vsync_r <= per_frame_vsync;
        per_frame_href_r  <= per_frame_href;
        per_frame_clken_r <= per_frame_clken;
        per_img_Bit_r     <= per_img_Bit;
    end
end

wire vsync_pos_flag = per_frame_vsync & (~per_frame_vsync_r);
wire vsync_neg_flag = (~per_frame_vsync) & per_frame_vsync_r;

//------------------------------------------
// 行/场方向计数
reg [10:0]  x_cnt, y_cnt;

always@(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin
        x_cnt <= 10'd0;
        y_cnt <= 10'd0;
    end else if(vsync_pos_flag) begin
        x_cnt <= 10'd0;
        y_cnt <= 10'd0;
    end else if(per_frame_clken) begin
        if(x_cnt < IMG_HDISP - 1) begin
            x_cnt <= x_cnt + 1'b1;
        end else begin
            x_cnt <= 10'd0;
            y_cnt <= y_cnt + 1'b1;
        end
    end
end

//------------------------------------------
// 竖直方向投影
reg   ram_wr;
wire [9:0] ram_wr_data;
wire [9:0] ram_rd_data;
wire [15:0] ram_wr_data_y;
wire [15:0] ram_rd_data_y;

always @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        ram_wr <= 1'b0;
    end else if (y_cnt == 10'd0) begin
        ram_wr <= 1'b1; 
    end else if (per_frame_clken && per_img_Bit) begin
        ram_wr <= 1'b1; 
    end else begin
        ram_wr <= 1'b0;
    end
end


assign ram_wr_data = (y_cnt == 10'd0) ? 16'd0 : 
                     per_img_Bit_r ? ram_rd_data + 1'b1 : ram_rd_data;

assign ram_wr_data_y = (y_cnt == 10'd0) ? 16'd0 : 
                       per_img_Bit_r ? ram_rd_data_y + y_cnt : ram_rd_data_y;


 ram u_ram_0 (
        .we(ram_wr),
        .waddr(x_cnt),
        .wdata_a(ram_wr_data),
        .rdata_b(ram_rd_data),
        .raddr(x_cnt),
        .clk(clk)
    );


 ram u_ram_1 (
        .we(ram_wr),
        .waddr(x_cnt),
        .wdata_a(ram_wr_data_y),
        .rdata_b(ram_rd_data_y),
        .raddr(x_cnt),
        .clk(clk)
    );
//------------------------------------------
// 根据RAM中统计的投影结果，判断最大与次大
reg [10:0]  x_max_1reg, x_max_2reg;
reg [15:0]  y_max_1reg_sum, y_max_2reg_sum;
reg [9:0]   x_max_1data, x_max_2data;

//always @(posedge clk or negedge rst_n) begin
//    if (!rst_n || vsync_pos_flag) begin
//        x_max_1reg <= 11'd0;
//        x_max_2reg <= 11'd0;
//        y_max_1reg_sum <= 16'd0;
//        y_max_2reg_sum <= 16'd0;
//        x_max_1data <= 10'd0;
//        x_max_2data <= 10'd0;
//    end else if (per_frame_clken && y_cnt == IMG_VDISP - 1'b1) begin
//        if (ram_rd_data > x_max_1data) begin
//            x_max_2data <= x_max_1data;
//            x_max_2reg <= x_max_1reg;
//            y_max_2reg_sum <= y_max_1reg_sum;
//
//            x_max_1data <= ram_rd_data;
//            x_max_1reg <= x_cnt;
//            y_max_1reg_sum <= ram_rd_data_y;
//        end else if (ram_rd_data > x_max_2data && x_cnt != x_max_1reg) begin
//            x_max_2data <= ram_rd_data;
//            x_max_2reg <= x_cnt;
//            y_max_2reg_sum <= ram_rd_data_y;
//        end
//    end
//end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n || vsync_pos_flag) begin
        x_max_1reg <= 11'd0;
        x_max_2reg <= 11'd0;
        y_max_1reg_sum <= 16'd0;
        y_max_2reg_sum <= 16'd0;
        x_max_1data <= 10'd0;
        x_max_2data <= 10'd0;
    end 
    // 在倒数第二行找到最大值
    else if (per_frame_clken && y_cnt == IMG_VDISP - 2'd2) begin
        if (ram_rd_data > x_max_1data) begin
            x_max_1data <= ram_rd_data;
            x_max_1reg <= x_cnt;
            y_max_1reg_sum <= ram_rd_data_y;
        end
    end
    // 在最后一行找到距离最大值超过150列的次大值
    else if (per_frame_clken && y_cnt == IMG_VDISP - 2'd1) begin
        if (ram_rd_data > x_max_2data && 
           ((x_cnt > x_max_1reg + 150) || (x_cnt < x_max_1reg - 150))) begin
            x_max_2data <= ram_rd_data;
            x_max_2reg <= x_cnt;
            y_max_2reg_sum <= ram_rd_data_y;
        end
    end
end

// 寄存器用于保存中间结果的分配
reg [15:0] y_max_1_sum_stage1, y_max_2_sum_stage1;
reg [15:0] y_max_1_sum_stage2, y_max_2_sum_stage2;
reg [15:0] y_max_1_sum_stage3, y_max_2_sum_stage3;
reg [10:0] x_max_1data_stage1, x_max_2data_stage1;
reg [10:0] x_max_1data_stage2, x_max_2data_stage2;
reg [10:0] x_max_1data_stage3, x_max_2data_stage3;

// 输出寄存器
reg [15:0] y_max_1_div_result, y_max_2_div_result;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 重置所有流水线寄存器
        y_max_1_sum_stage1 <= 16'd0;
        y_max_2_sum_stage1 <= 16'd0;
        y_max_1_sum_stage2 <= 16'd0;
        y_max_2_sum_stage2 <= 16'd0;
        y_max_1_sum_stage3 <= 16'd0;
        y_max_2_sum_stage3 <= 16'd0;
        y_max_1_div_result <= 16'd0;
        y_max_2_div_result <= 16'd0;
        x_max_1data_stage1 <= 11'd0;
        x_max_2data_stage1 <= 11'd0;
        x_max_1data_stage2 <= 11'd0;
        x_max_2data_stage2 <= 11'd0;
        x_max_1data_stage3 <= 11'd0;
        x_max_2data_stage3 <= 11'd0;
    end else if (vsync_neg_flag) begin
        // 第一级流水：加载输入数据
        y_max_1_sum_stage1 <= y_max_1reg_sum;
        y_max_2_sum_stage1 <= y_max_2reg_sum;
        x_max_1data_stage1 <= x_max_1data;
        x_max_2data_stage1 <= x_max_2data;

        // 第二级流水：处理部分数据
        y_max_1_sum_stage2 <= y_max_1_sum_stage1;
        y_max_2_sum_stage2 <= y_max_2_sum_stage1;
        x_max_1data_stage2 <= x_max_1data_stage1;
        x_max_2data_stage2 <= x_max_2data_stage1;

        // 第三级流水：计算除法
        y_max_1_sum_stage3 <= y_max_1_sum_stage2;
        y_max_2_sum_stage3 <= y_max_2_sum_stage2;
        x_max_1data_stage3 <= x_max_1data_stage2;
        x_max_2data_stage3 <= x_max_2data_stage2;

        // 第四级流水：完成除法运算并输出
        y_max_1_div_result <= (x_max_1data_stage3 != 0) ? (y_max_1_sum_stage3 / x_max_1data_stage3) : 16'd0;
        y_max_2_div_result <= (x_max_2data_stage3 != 0) ? (y_max_2_sum_stage3 / x_max_2data_stage3) : 16'd0;

        // 将计算结果赋值给输出
        x_max_1 <= x_max_1reg;
        x_max_2 <= x_max_2reg;
        y_max_1 <= y_max_1_div_result;
        y_max_2 <= y_max_2_div_result;
    end
end

// Coordinates validity signal assignment
assign coords_valid = (x_max_1 != 11'd0) && (x_max_2 != 11'd0) && (y_max_1 != 16'd0) && (y_max_2 != 16'd0);

endmodule
