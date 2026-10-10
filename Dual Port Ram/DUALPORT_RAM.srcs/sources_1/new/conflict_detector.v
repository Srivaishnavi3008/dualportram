`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 13:23:25
// Design Name: 
// Module Name: conflict_detector
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

module conflict_detector #(
    parameter ADDR_WIDTH = 6
)(
    input req_a,
    input req_b,
    input  [ADDR_WIDTH-1:0] addr_a,
    input  [ADDR_WIDTH-1:0] addr_b,

    output conflict
);

assign conflict = req_a && req_b && (addr_a == addr_b);

endmodule
