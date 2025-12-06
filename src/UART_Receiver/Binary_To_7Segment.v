module Binary_To_7Segment
(   input       i_Clk,
    input [3:0] i_Binary_Num,
    output      o_Segment_A,
    output      o_Segment_B,
    output      o_Segment_C,
    output      o_Segment_D,
    output      o_Segment_E,
    output      o_Segment_F,
    output      o_Segment_G);

reg [6:0]       r_Hex_Encoding;

always @(posedge i_Clk)
    begin
        case (i_Binary_Num)
            4'b0000 : r_Hex_Encoding <= 7'b1111110; // 0x7E
            4'b0001 : r_Hex_Encoding <= 7'b0110000; // 0x30
            4'b0010 : r_Hex_Encoding <= 7'b1101101; // 0x6D
            4'b0011 : r_Hex_Encoding <= 7'b1111001; // 0x79
            4'b0100 : r_Hex_Encoding <= 7'b0110011; // 0x33
            4'b0101 : r_Hex_Encoding <= 7'b1011011; // 0x5B
            4'b0110 : r_Hex_Encoding <= 7'b1011111; // 0x5F
            4'b0111 : r_Hex_Encoding <= 7'b1110000; // 0x70
            4'b1000 : r_Hex_Encoding <= 7'b1111111; // 0x7F
            4'b1001 : r_Hex_Encoding <= 7'b1111011; // 0x7B
            4'b1010 : r_Hex_Encoding <= 7'b1110111; // 0x77
            4'b1011 : r_Hex_Encoding <= 7'b0011111; // 0x1F
            4'b1100 : r_Hex_Encoding <= 7'b1001110; // 0x4E
            4'b1101 : r_Hex_Encoding <= 7'b0111101; // 0x3D
            4'b1110 : r_Hex_Encoding <= 7'b1001111; // 0x4F
            4'b1111 : r_Hex_Encoding <= 7'b1000111; // 0x47
            default : r_Hex_Encoding <= 7'b0000000; // 0x00
        endcase
    end

assign o_Segment_A = r_Hex_Encoding[6];
assign o_Segment_B = r_Hex_Encoding[5];
assign o_Segment_C = r_Hex_Encoding[4];
assign o_Segment_D = r_Hex_Encoding[3];
assign o_Segment_E = r_Hex_Encoding[2];
assign o_Segment_F = r_Hex_Encoding[1];
assign o_Segment_G = r_Hex_Encoding[0];

endmodule
