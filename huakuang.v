`timescale 1ns / 1ps
module huakuang
#(
    parameter [10:0] IMG_HDISP = 11'd1280,    // Image width
    parameter [10:0] IMG_VDISP = 11'd720,     // Image height
    parameter [9:0] BOX_WIDTH = 10'd100,      // Box width
    parameter [9:0] BOX_HEIGHT = 10'd100,     // Box height
    parameter [3:0] BORDER_THICKNESS = 4'd2   // Border thickness
)(
    input            clk,
    input            rst_n,
    input            per_frame_clken,         // Pixel clock enable
    input            per_frame_vsync,
    input            per_frame_href,
    input  [10:0]    max_x_1,                 // Spot 1 X coordinate
    input  [15:0]    y_avg_1,                 // Spot 1 Y coordinate
    input  [10:0]    max_x_2,                 // Spot 2 X coordinate
    input  [15:0]    y_avg_2,                 // Spot 2 Y coordinate
    input  [23:0]    per_img_Bit,             // Input RGB pixel (24-bit)
    output           post_frame_vsync,
    output           post_frame_href,
    output           post_frame_clken,
    output [23:0]    post_img_Bit             // Output RGB pixel (24-bit)
);

    // Synchronize frame signals
    reg per_frame_vsync_r, per_frame_href_r, per_frame_clken_r;
    reg [23:0] per_img_Bit_r;

    assign post_frame_vsync = per_frame_vsync_r;
    assign post_frame_href = per_frame_href_r;
    assign post_frame_clken = per_frame_clken_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_frame_vsync_r <= 0;
            per_frame_href_r <= 0;
            per_frame_clken_r <= 0;
            per_img_Bit_r <= 0;
        end else begin
            per_frame_vsync_r <= per_frame_vsync;
            per_frame_href_r <= per_frame_href;
            per_frame_clken_r <= per_frame_clken;
            per_img_Bit_r <= per_img_Bit;
        end
    end

    // Position counters for pixel location
    reg [10:0] x_cnt, y_cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_cnt <= 0;
            y_cnt <= 0;
        end else if (per_frame_clken) begin
            if (x_cnt < IMG_HDISP - 1) begin
                x_cnt <= x_cnt + 1;
            end else begin
                x_cnt <= 0;
                if (y_cnt < IMG_VDISP - 1) begin
                    y_cnt <= y_cnt + 1;
                end else begin
                    y_cnt <= 0;
                end
            end
        end
    end

    // Delay position counters to align with delayed pixel data
    reg [10:0] x_cnt_d, y_cnt_d;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x_cnt_d <= 0;
            y_cnt_d <= 0;
        end else begin
            x_cnt_d <= x_cnt;
            y_cnt_d <= y_cnt;
        end
    end

    // Detect falling edge of per_frame_vsync to latch spot positions
    reg per_frame_vsync_r0, per_frame_vsync_r1;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            per_frame_vsync_r0 <= 0;
            per_frame_vsync_r1 <= 0;
        end else begin
            per_frame_vsync_r0 <= per_frame_vsync;
            per_frame_vsync_r1 <= per_frame_vsync_r0;
        end
    end
    wire vsync_falling_edge = per_frame_vsync_r1 && !per_frame_vsync_r0;

    // Latch spot positions at the start of each frame
    reg [10:0] max_x_1_r, y_avg_1_r;
    reg [10:0] max_x_2_r, y_avg_2_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            max_x_1_r <= 0;
            y_avg_1_r <= 0;
            max_x_2_r <= 0;
            y_avg_2_r <= 0;
        end else if (vsync_falling_edge) begin
            max_x_1_r <= max_x_1;
            y_avg_1_r <= y_avg_1;
            max_x_2_r <= max_x_2;
            y_avg_2_r <= y_avg_2;
        end
    end

    // Update box boundaries once per frame, avoid drawing at image edges
    reg [10:0] box1_x_min, box1_x_max, box1_y_min, box1_y_max;
    reg [10:0] box2_x_min, box2_x_max, box2_y_min, box2_y_max;
    reg        box1_valid, box2_valid;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            box1_x_min <= 0;
            box1_x_max <= 0;
            box1_y_min <= 0;
            box1_y_max <= 0;
            box1_valid <= 0;
            box2_x_min <= 0;
            box2_x_max <= 0;
            box2_y_min <= 0;
            box2_y_max <= 0;
            box2_valid <= 0;
        end else if (vsync_falling_edge) begin
            // Ensure the box doesn't go beyond image boundaries
            if (max_x_1_r > (BOX_WIDTH >> 1) + BORDER_THICKNESS &&
                y_avg_1_r > (BOX_HEIGHT >> 1) + BORDER_THICKNESS &&
                max_x_1_r + (BOX_WIDTH >> 1) < IMG_HDISP - BORDER_THICKNESS &&
                y_avg_1_r + (BOX_HEIGHT >> 1) < IMG_VDISP - BORDER_THICKNESS) begin
                box1_x_min <= max_x_1_r - (BOX_WIDTH >> 1);
                box1_x_max <= max_x_1_r + (BOX_WIDTH >> 1);
                box1_y_min <= y_avg_1_r - (BOX_HEIGHT >> 1);
                box1_y_max <= y_avg_1_r + (BOX_HEIGHT >> 1);
                box1_valid <= 1;
            end else begin
                box1_valid <= 0;
            end

            if (max_x_2_r > (BOX_WIDTH >> 1) + BORDER_THICKNESS &&
                y_avg_2_r > (BOX_HEIGHT >> 1) + BORDER_THICKNESS &&
                max_x_2_r + (BOX_WIDTH >> 1) < IMG_HDISP - BORDER_THICKNESS &&
                y_avg_2_r + (BOX_HEIGHT >> 1) < IMG_VDISP - BORDER_THICKNESS) begin
                box2_x_min <= max_x_2_r - (BOX_WIDTH >> 1);
                box2_x_max <= max_x_2_r + (BOX_WIDTH >> 1);
                box2_y_min <= y_avg_2_r - (BOX_HEIGHT >> 1);
                box2_y_max <= y_avg_2_r + (BOX_HEIGHT >> 1);
                box2_valid <= 1;
            end else begin
                box2_valid <= 0;
            end
        end
    end

    // Border detection with simplified conditions
    wire in_box1 = box1_valid && (
                   (x_cnt_d >= box1_x_min && x_cnt_d <= box1_x_max &&
                    (y_cnt_d >= box1_y_min && y_cnt_d < box1_y_min + BORDER_THICKNESS || 
                     y_cnt_d >= box1_y_max - BORDER_THICKNESS && y_cnt_d <= box1_y_max)) ||
                   (y_cnt_d >= box1_y_min && y_cnt_d <= box1_y_max &&
                    (x_cnt_d >= box1_x_min && x_cnt_d < box1_x_min + BORDER_THICKNESS ||
                     x_cnt_d >= box1_x_max - BORDER_THICKNESS && x_cnt_d <= box1_x_max))
                   );

    wire in_box2 = box2_valid && (
                   (x_cnt_d >= box2_x_min && x_cnt_d <= box2_x_max &&
                    (y_cnt_d >= box2_y_min && y_cnt_d < box2_y_min + BORDER_THICKNESS || 
                     y_cnt_d >= box2_y_max - BORDER_THICKNESS && y_cnt_d <= box2_y_max)) ||
                   (y_cnt_d >= box2_y_min && y_cnt_d <= box2_y_max &&
                    (x_cnt_d >= box2_x_min && x_cnt_d < box2_x_min + BORDER_THICKNESS ||
                     x_cnt_d >= box2_x_max - BORDER_THICKNESS && x_cnt_d <= box2_x_max))
                   );

    // Set red border color (RGB: FF0000)
    wire [23:0] red_border_color = 24'hFF0000;
    
    // Output image pixel (corrected for full-screen red and jumping issues)
    assign post_img_Bit = (per_frame_href_r && (in_box1 || in_box2)) ? red_border_color : per_img_Bit_r;

endmodule
