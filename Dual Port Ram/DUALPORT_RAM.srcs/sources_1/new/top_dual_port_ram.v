`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 13:28:51
// Design Name: 
// Module Name: top_dual_port_ram
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
module top_dual_port_ram #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 8,
    parameter AGING_WIDTH = 3,
    parameter DEPTH = 64
)(
    input clk,
    input rst,

    // PORT A
    input req_a,
    input  [ADDR_WIDTH-1:0] addr_a,
    input wr_en_a,
    input rd_en_a,
    input  [DATA_WIDTH-1:0] data_in_a,
    output [DATA_WIDTH-1:0] data_out_a,

    // PORT B
    input req_b,
    input  [ADDR_WIDTH-1:0] addr_b,
    input wr_en_b,
    input rd_en_b,
    input  [DATA_WIDTH-1:0] data_in_b,
    output [DATA_WIDTH-1:0] data_out_b,

    // Debug / observation outputs
    output conflict,
    output grant_a,
    output grant_b,
    output [AGING_WIDTH-1:0] aging_a,
    output [AGING_WIDTH-1:0] aging_b
);

wire sel_port;
wire [ADDR_WIDTH-1:0] addr_sel;


// ------------------------------------
// 1. CONFLICT DETECTOR
// ------------------------------------

conflict_detector #(
    .ADDR_WIDTH(ADDR_WIDTH)
)
u_conflict_detector (
    .req_a(req_a),
    .req_b(req_b),
    .addr_a(addr_a),
    .addr_b(addr_b),
    .conflict(conflict)
);


// ------------------------------------
// 2. PRIORITY CONTROLLER
// ------------------------------------

priority_controller #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .AGING_WIDTH(AGING_WIDTH)
)
u_priority_controller (
    .clk(clk),
    .rst(rst),

    .req_a(req_a),
    .req_b(req_b),

    .addr_a(addr_a),
    .addr_b(addr_b),

    .conflict(conflict),

    .aging_a(aging_a),
    .aging_b(aging_b),

    .grant_a(grant_a),
    .grant_b(grant_b),

    .sel_port(sel_port),
    .addr_sel(addr_sel)
);


// ------------------------------------
// 3. AGING COUNTER
// ------------------------------------

aging_counter #(
    .AGING_WIDTH(AGING_WIDTH)
)
u_aging_counter (
    .clk(clk),
    .rst(rst),

    .req_a(req_a),
    .req_b(req_b),

    .grant_a(grant_a),
    .grant_b(grant_b),

    .aging_a(aging_a),
    .aging_b(aging_b)
);


// ------------------------------------
// 4. DUAL PORT RAM
// ------------------------------------

dual_port_ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(DEPTH)
)
u_dual_port_ram (
    .clk(clk),

    .addr_a(addr_a),
    .addr_b(addr_b),

    .wr_en_a(wr_en_a),
    .wr_en_b(wr_en_b),

    .rd_en_a(rd_en_a),
    .rd_en_b(rd_en_b),

    .grant_a(grant_a),
    .grant_b(grant_b),

    .data_in_a(data_in_a),
    .data_in_b(data_in_b),

    .data_out_a(data_out_a),
    .data_out_b(data_out_b)
);

endmodule
