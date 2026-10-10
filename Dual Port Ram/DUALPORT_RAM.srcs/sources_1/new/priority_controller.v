`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.10.2026 13:25:39
// Design Name: 
// Module Name: priority_controller
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
module priority_controller #(
    parameter ADDR_WIDTH = 6,
    parameter AGING_WIDTH = 3
)(
    input clk,
    input rst,

    input req_a,
    input req_b,

    input  [ADDR_WIDTH-1:0] addr_a,
    input  [ADDR_WIDTH-1:0] addr_b,

    input conflict,

    input  [AGING_WIDTH-1:0] aging_a,
    input  [AGING_WIDTH-1:0] aging_b,

    output reg grant_a,
    output reg grant_b,

    output reg sel_port,

    output reg [ADDR_WIDTH-1:0] addr_sel
);

reg last_grant;

always @(*)
begin
    grant_a = 1'b0;
    grant_b = 1'b0;

    sel_port = 1'b0;
    addr_sel = {ADDR_WIDTH{1'b0}};

    // Only A requests
    if (req_a && !req_b)
    begin
        grant_a = 1'b1;
        sel_port = 1'b0;
        addr_sel = addr_a;
    end

    // Only B requests
    else if (!req_a && req_b)
    begin
        grant_b = 1'b1;
        sel_port = 1'b1;
        addr_sel = addr_b;
    end

    // Both request
    else if (req_a && req_b)
    begin
        // No conflict: both ports can access different addresses
        if (!conflict)
        begin
            grant_a = 1'b1;
            grant_b = 1'b1;
        end

        // Conflict exists
        else
        begin
            // Aging decides when one has waited longer
            if (aging_a > aging_b)
            begin
                grant_a = 1'b1;
                sel_port = 1'b0;
                addr_sel = addr_a;
            end

            else if (aging_b > aging_a)
            begin
                grant_b = 1'b1;
                sel_port = 1'b1;
                addr_sel = addr_b;
            end

            // Same aging -> Round Robin
            else
            begin
                if (last_grant == 1'b0)
                begin
                    grant_b = 1'b1;
                    sel_port = 1'b1;
                    addr_sel = addr_b;
                end
                else
                begin
                    grant_a = 1'b1;
                    sel_port = 1'b0;
                    addr_sel = addr_a;
                end
            end
        end
    end
end


// Round-Robin pointer
always @(posedge clk or posedge rst)
begin
    if (rst)
        last_grant <= 1'b0;

    else
    begin
        if (grant_a && !grant_b)
            last_grant <= 1'b0;

        else if (grant_b && !grant_a)
            last_grant <= 1'b1;
    end
end

endmodule
