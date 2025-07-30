module tops(
    input i_clk,
    input i_rst,
    input [7:0] i_I0,
    output [7:0] o_Ifilter,
    output [7:0] o_Ifilter2
);

parameter LEN = 256;  // Image length
parameter g11 = 3, g12 = 14, g13 = 22, g14 = 14, g15 = 3;
parameter g21 = 14, g22 = 61, g23 = 101, g24 = 61, g25 = 14;
parameter g31 = 22, g32 = 101, g33 = 166, g34 = 101, g35 = 22;
parameter g41 = 14, g42 = 61, g43 = 101, g44 = 61, g45 = 14;
parameter g51 = 3, g52 = 14, g53 = 22, g54 = 14, g55 = 3;

// Image buffer to store pixel data
integer i;
reg [7:0] image_buff[LEN + LEN + LEN + LEN + 1:1];  // Storing image data

// Matrix values for convolution
reg [7:0] mat11, mat12, mat13, mat14, mat15;
reg [7:0] mat21, mat22, mat23, mat24, mat25;
reg [7:0] mat31, mat32, mat33, mat34, mat35;
reg [7:0] mat41, mat42, mat43, mat44, mat45;
reg [7:0] mat51, mat52, mat53, mat54, mat55;

// Image buffer update logic
always @(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        // Reset the image buffer
        for (i = 1; i <= LEN + LEN + LEN + LEN + 1; i = i + 1)
            image_buff[i] <= 8'd0;
    end else begin
        // Shift the image buffer
        image_buff[1] <= i_I0;
        for (i = 2; i <= LEN + LEN + LEN + LEN + 1; i = i + 1)
            image_buff[i] <= image_buff[i - 1];
    end
end

// Update the matrix registers
always @(posedge i_clk or posedge i_rst)
begin
    if (i_rst) begin
        // Reset the matrix values
        mat11 <= 8'd0; mat12 <= 8'd0; mat13 <= 8'd0; mat14 <= 8'd0; mat15 <= 8'd0;
        mat21 <= 8'd0; mat22 <= 8'd0; mat23 <= 8'd0; mat24 <= 8'd0; mat25 <= 8'd0;
        mat31 <= 8'd0; mat32 <= 8'd0; mat33 <= 8'd0; mat34 <= 8'd0; mat35 <= 8'd0;
        mat41 <= 8'd0; mat42 <= 8'd0; mat43 <= 8'd0; mat44 <= 8'd0; mat45 <= 8'd0;
        mat51 <= 8'd0; mat52 <= 8'd0; mat53 <= 8'd0; mat54 <= 8'd0; mat55 <= 8'd0;
    end else begin
        // Shift the matrix values to simulate the 5x5 convolution window
        mat11 <= image_buff[1];   mat12 <= mat11; mat13 <= mat12; mat14 <= mat13; mat15 <= mat14;
        mat21 <= image_buff[1 + LEN]; mat22 <= mat21; mat23 <= mat22; mat24 <= mat23; mat25 <= mat24;
        mat31 <= image_buff[1 + LEN + LEN]; mat32 <= mat31; mat33 <= mat32; mat34 <= mat33; mat35 <= mat34;
        mat41 <= image_buff[1 + LEN + LEN + LEN]; mat42 <= mat41; mat43 <= mat42; mat44 <= mat43; mat45 <= mat44;
        mat51 <= image_buff[1 + LEN + LEN + LEN + LEN]; mat52 <= mat51; mat53 <= mat52; mat54 <= mat53; mat55 <= mat54;
    end
end

// Calculate the weighted sum of the matrix
wire [12:0] wmat;
assign wmat = mat11 + mat12 + mat13 + mat14 + mat15 + 
             mat21 + mat22 + mat23 + mat24 + mat25 + 
             mat31 + mat32 + mat33 + mat34 + mat35 + 
             mat41 + mat42 + mat43 + mat44 + mat45 + 
             mat51 + mat52 + mat53 + mat54 + mat55;

// Calculate the threshold value
wire [7:0] wlvl = wmat[11:4];  // Only take the upper 8 bits of the weighted sum

// Output the filtered image and the thresholded image
assign o_Ifilter = (i_I0 >= wlvl) ? 8'd255 : 8'd0;
assign o_Ifilter2 = (i_I0 >= 128) ? 8'd255 : 8'd0;

endmodule
