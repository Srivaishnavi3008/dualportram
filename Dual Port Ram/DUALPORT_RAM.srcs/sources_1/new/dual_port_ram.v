`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 13:27:25
// Design Name: 
// Module Name: dual_port_ram
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

module dual_port_ram #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 64
)(
    input clk,

    input  [ADDR_WIDTH-1:0] addr_a,
    input  [ADDR_WIDTH-1:0] addr_b,

    input wr_en_a,
    input wr_en_b,

    input rd_en_a,
    input rd_en_b,

    input grant_a,
    input grant_b,

    input  [DATA_WIDTH-1:0] data_in_a,
    input  [DATA_WIDTH-1:0] data_in_b,

    output reg [DATA_WIDTH-1:0] data_out_a,
    output reg [DATA_WIDTH-1:0] data_out_b
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

always @(posedge clk)
begin

    // Port A WRITE
    if (grant_a && wr_en_a)
        mem[addr_a] <= data_in_a;

    // Port B WRITE
    if (grant_b && wr_en_b)
        mem[addr_b] <= data_in_b;

    // Port A READ
    if (grant_a && rd_en_a)
        data_out_a <= mem[addr_a];

    // Port B READ
    if (grant_b && rd_en_b)
        data_out_b <= mem[addr_b];

end

endmodule
