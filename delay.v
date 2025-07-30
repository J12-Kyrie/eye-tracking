module image_delay(
    input clk,          // 时钟信号
    input rst_n,        // 复位信号（低电平有效）
    input frame_vsync,   // 原始帧的垂直同步信号
    input frame_href,    // 原始帧的水平同步信号
    input frame_clken,   // 原始帧的时钟使能信号
    input [23:0] in_img_Bit, // 输入的图像数据
    output reg post_frame_vsync, // 延迟后的垂直同步信号
    output reg post_frame_href,  // 延迟后的水平同步信号
    output reg post_frame_clken, // 延迟后的时钟使能信号
    output reg [23:0] post_img_Bit // 延迟后的图像数据
);

    // 定义两个存储帧数据的存储器
    reg [23:0] frame1[0:1023]; // 假设每帧有1024个像素
    reg [23:0] frame2[0:1023];
    reg [10:0] wr_ptr = 0; // 写指针
    reg [10:0] rd_ptr = 0; // 读指针

    // 状态定义
    localparam IDLE = 2'b00;
    localparam WRITE_FRAME1 = 2'b01;
    localparam WRITE_FRAME2 = 2'b10;
    localparam READ_FRAME1 = 2'b11;
    localparam READ_FRAME2 = 2'b100;
    
    reg [2:0] current_state, next_state;

    // 状态机切换逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // 状态机下一状态逻辑
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (frame_vsync)
                    next_state = WRITE_FRAME1;
                else
                    next_state = IDLE;
            end
            WRITE_FRAME1: begin
                if (wr_ptr == 1023)
                    next_state = WRITE_FRAME2;
                else
                    next_state = WRITE_FRAME1;
            end
            WRITE_FRAME2: begin
                if (wr_ptr == 1023)
                    next_state = READ_FRAME1;
                else
                    next_state = WRITE_FRAME2;
            end
            READ_FRAME1: begin
                if (rd_ptr == 1023)
                    next_state = READ_FRAME2;
                else
                    next_state = READ_FRAME1;
            end
            READ_FRAME2: begin
                if (rd_ptr == 1023)
                    next_state = WRITE_FRAME1;
                else
                    next_state = READ_FRAME2;
            end
            default: next_state = IDLE;
        endcase
    end

    // 写入和读取逻辑
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            post_frame_vsync <= 0;
            post_frame_href <= 0;
            post_frame_clken <= 0;
            post_img_Bit <= 0;
        end else begin
            case (current_state)
                WRITE_FRAME1: begin
                    frame1[wr_ptr] <= in_img_Bit;
                    if (wr_ptr == 1023)
                        wr_ptr <= 0;
                    else
                        wr_ptr <= wr_ptr + 1;
                end
                WRITE_FRAME2: begin
                    frame2[wr_ptr] <= in_img_Bit;
                    if (wr_ptr == 1023)
                        wr_ptr <= 0;
                    else
                        wr_ptr <= wr_ptr + 1;
                end
                READ_FRAME1: begin
                    post_img_Bit <= frame1[rd_ptr];
                    if (rd_ptr == 1023)
                        rd_ptr <= 0;
                    else
                        rd_ptr <= rd_ptr + 1;
                end
                READ_FRAME2: begin
                    post_img_Bit <= frame2[rd_ptr];
                    if (rd_ptr == 1023)
                        rd_ptr <= 0;
                    else
                        rd_ptr <= rd_ptr + 1;
                end
            endcase

            // 同步信号的延迟处理
            post_frame_vsync <= frame_vsync;
            post_frame_href <= frame_href;
            post_frame_clken <= frame_clken;
        end
    end

endmodule
