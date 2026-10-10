`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 13:24:17
// Design Name: 
// Module Name: aging_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module aging_counter #(
    parameter AGING_WIDTH = 3
)(
    input clk,
    input rst,

    input req_a,
    input req_b,

    input grant_a,
    input grant_b,

    output reg [AGING_WIDTH-1:0] aging_a,
    output reg [AGING_WIDTH-1:0] aging_b
);

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        aging_a <= 0;
        aging_b <= 0;
    end
    else
    begin
        // Port A
        if (grant_a)
            aging_a <= 0;
        else if (req_a && (aging_a != {AGING_WIDTH{1'b1}}))
            aging_a <= aging_a + 1'b1;

        // Port B
        if (grant_b)
            aging_b <= 0;
        else if (req_b && (aging_b != {AGING_WIDTH{1'b1}}))
            aging_b <= aging_b + 1'b1;
    end
end

endmodule
