`timescale 1ns / 1ps

module tb_top_dual_port_ram;

reg clk;
reg rst;

// PORT A
reg req_a;
reg [5:0] addr_a;
reg wr_en_a;
reg rd_en_a;
reg [7:0] data_in_a;
wire [7:0] data_out_a;

// PORT B
reg req_b;
reg [5:0] addr_b;
reg wr_en_b;
reg rd_en_b;
reg [7:0] data_in_b;
wire [7:0] data_out_b;

// CONTROL SIGNALS
wire conflict;
wire grant_a;
wire grant_b;
wire [2:0] aging_a;
wire [2:0] aging_b;


//--------------------------------------------------
// DUT
//--------------------------------------------------

top_dual_port_ram DUT
(
    .clk(clk),
    .rst(rst),

    .req_a(req_a),
    .addr_a(addr_a),
    .wr_en_a(wr_en_a),
    .rd_en_a(rd_en_a),
    .data_in_a(data_in_a),
    .data_out_a(data_out_a),

    .req_b(req_b),
    .addr_b(addr_b),
    .wr_en_b(wr_en_b),
    .rd_en_b(rd_en_b),
    .data_in_b(data_in_b),
    .data_out_b(data_out_b),

    .conflict(conflict),
    .grant_a(grant_a),
    .grant_b(grant_b),

    .aging_a(aging_a),
    .aging_b(aging_b)
);


//--------------------------------------------------
// CLOCK
//--------------------------------------------------

always #5 clk = ~clk;


//--------------------------------------------------
// TEST SEQUENCE
//--------------------------------------------------

initial
begin

    // INITIAL VALUES
    clk = 0;
    rst = 1;

    req_a = 0;
    req_b = 0;

    addr_a = 0;
    addr_b = 0;

    wr_en_a = 0;
    wr_en_b = 0;

    rd_en_a = 0;
    rd_en_b = 0;

    data_in_a = 0;
    data_in_b = 0;


    //--------------------------------------------------
    // RESET
    //--------------------------------------------------

    #20;
    rst = 0;

    $display("==============================================");
    $display("DUAL PORT RAM ARBITRATION TEST STARTED");
    $display("==============================================");


    //--------------------------------------------------
    // TEST 1 : PORT A WRITE
    //--------------------------------------------------

    $display("\nTEST 1 : PORT A WRITE");

    req_a = 1;
    addr_a = 6'd10;
    wr_en_a = 1;
    data_in_a = 8'h55;

    #20;

    req_a = 0;
    wr_en_a = 0;

    $display("Port A wrote 55 to Address 10");



    //--------------------------------------------------
    // TEST 2 : PORT B WRITE
    //--------------------------------------------------

    #10;

    $display("\nTEST 2 : PORT B WRITE");

    req_b = 1;
    addr_b = 6'd20;
    wr_en_b = 1;
    data_in_b = 8'hAA;

    #20;

    req_b = 0;
    wr_en_b = 0;

    $display("Port B wrote AA to Address 20");



    //--------------------------------------------------
    // TEST 3 : PORT A READ
    //--------------------------------------------------

    #10;

    $display("\nTEST 3 : PORT A READ");

    req_a = 1;
    addr_a = 6'd10;
    rd_en_a = 1;

    #10;

    if (data_out_a == 8'h55)
        $display("PASS : Port A read = %h", data_out_a);
    else
        $display("ERROR : Port A expected 55, got %h",
                 data_out_a);

    req_a = 0;
    rd_en_a = 0;



    //--------------------------------------------------
    // TEST 4 : PORT B READ
    //--------------------------------------------------

    #10;

    $display("\nTEST 4 : PORT B READ");

    req_b = 1;
    addr_b = 6'd20;
    rd_en_b = 1;

    #10;

    if (data_out_b == 8'hAA)
        $display("PASS : Port B read = %h", data_out_b);
    else
        $display("ERROR : Port B expected AA, got %h",
                 data_out_b);

    req_b = 0;
    rd_en_b = 0;



    //--------------------------------------------------
    // TEST 5 : SIMULTANEOUS DIFFERENT ADDRESS ACCESS
    //--------------------------------------------------

    #10;

    $display("\nTEST 5 : SIMULTANEOUS DIFFERENT ADDRESS ACCESS");

    req_a = 1;
    req_b = 1;

    addr_a = 6'd30;
    addr_b = 6'd40;

    wr_en_a = 1;
    wr_en_b = 1;

    data_in_a = 8'h11;
    data_in_b = 8'h22;

    #10;

    if ((conflict == 0) && (grant_a == 1) && (grant_b == 1))
        $display("PASS : No conflict, both ports granted");
    else
        $display("ERROR : Different addresses not handled correctly");

    #10;

    req_a = 0;
    req_b = 0;

    wr_en_a = 0;
    wr_en_b = 0;



    //--------------------------------------------------
    // TEST 6 : SAME ADDRESS CONFLICT
    //--------------------------------------------------

    #10;

    $display("\nTEST 6 : SAME ADDRESS CONFLICT");

    req_a = 1;
    req_b = 1;

    addr_a = 6'd50;
    addr_b = 6'd50;

    wr_en_a = 0;
    wr_en_b = 0;

    rd_en_a = 1;
    rd_en_b = 1;

    #10;

    if (conflict == 1)
        $display("PASS : Conflict detected");
    else
        $display("ERROR : Conflict not detected");


    if ((grant_a == 1 && grant_b == 0) ||
        (grant_a == 0 && grant_b == 1))
        $display("PASS : Only one port granted during conflict");
    else
        $display("ERROR : Invalid grants during conflict");


    #10;

    req_a = 0;
    req_b = 0;

    rd_en_a = 0;
    rd_en_b = 0;



    //--------------------------------------------------
    // TEST 7 : AGING AND ROUND ROBIN
    //--------------------------------------------------

    #10;

    $display("\nTEST 7 : AGING + ROUND ROBIN FAIRNESS");

    req_a = 1;
    req_b = 1;

    addr_a = 6'd50;
    addr_b = 6'd50;

    wr_en_a = 0;
    wr_en_b = 0;

    rd_en_a = 1;
    rd_en_b = 1;


    // Run several clock cycles
    repeat(8)
    begin
        #10;

        $display("Time=%0t | Grant_A=%b Grant_B=%b | Aging_A=%d Aging_B=%d",
                 $time,
                 grant_a,
                 grant_b,
                 aging_a,
                 aging_b);

        // Mutual exclusion check
        if (grant_a && grant_b)
            $display("ERROR : Both ports granted during conflict");
    end


    req_a = 0;
    req_b = 0;

    rd_en_a = 0;
    rd_en_b = 0;



    //--------------------------------------------------
    // TEST 8 : VERIFY KNOWN READ DATA
    //--------------------------------------------------

    #10;

    $display("\nTEST 8 : FINAL DATA VERIFICATION");

    // Read address 10 using Port A
    req_a = 1;
    addr_a = 6'd10;
    rd_en_a = 1;

    #10;

    if (data_out_a == 8'h55)
        $display("PASS : Address 10 contains 55");
    else
        $display("ERROR : Address 10 expected 55, got %h",
                 data_out_a);

    req_a = 0;
    rd_en_a = 0;


    #10;

    // Read address 20 using Port B
    req_b = 1;
    addr_b = 6'd20;
    rd_en_b = 1;

    #10;

    if (data_out_b == 8'hAA)
        $display("PASS : Address 20 contains AA");
    else
        $display("ERROR : Address 20 expected AA, got %h",
                 data_out_b);

    req_b = 0;
    rd_en_b = 0;



    //--------------------------------------------------
    // END
    //--------------------------------------------------

    #20;

    $display("\n==============================================");
    $display("ALL TESTS COMPLETED");
    $display("==============================================");

  

end

endmodule