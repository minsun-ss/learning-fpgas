module Danger_Latch(
    input i_Switch_1,
    input i_Switch_2,
    output o_Segment1_A);

always @ (i_Switch_1 or i_Switch_2)
begin
    if (i_Switch_1 == 1'b0 && i_Switch_2 == 1'b0)
      o_Segment1_A <= 1'b0;
    else if (i_Switch_1 == 1'b0 && i_Switch_2 == 1'b1)
      o_Segment1_A <= 1'b1;
    else if (i_Switch_1 == 1'b1 && i_Switch_2 == 1'b0)
      o_Segment1_A <= 1'b1;
end

endmodule
