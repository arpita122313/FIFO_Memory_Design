// =============================================================================
// Project       : Synchronous FIFO Memory Design
// Module        : fifo_tb
// File          : fifo_tb.v
// Description   : Comprehensive Self-Checking Testbench verifying all functional
//                 features, edge cases, flags, overflow/underflow, and wraparound.
// Standard      : IEEE 1364-2001 (Verilog-2001)
// =============================================================================

`timescale 1ns / 1ps

module fifo_tb;

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    parameter DATA_WIDTH = 8;
    parameter DEPTH      = 16;
    parameter ADDR_WIDTH = 4;
    parameter CLK_PERIOD = 10; // 100 MHz clock period (10 ns)

    // -------------------------------------------------------------------------
    // DUT Interface Signals
    // -------------------------------------------------------------------------
    reg                   clk;
    reg                   rst;
    reg                   wr_en;
    reg                   rd_en;
    reg  [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire                  full;
    wire                  empty;

    // -------------------------------------------------------------------------
    // Verification & Scoreboard Variables
    // -------------------------------------------------------------------------
    integer total_tests;
    integer passed_tests;
    integer failed_tests;
    integer i;

    // Golden FIFO Queue Model for Autonomous Data Integrity Checking
    reg [DATA_WIDTH-1:0] golden_queue [0:511];
    integer q_wr_idx;
    integer q_rd_idx;
    integer q_count;

    // -------------------------------------------------------------------------
    // Device Under Test (DUT) Instantiation
    // -------------------------------------------------------------------------
    fifo_top #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) dut (
        .clk   (clk),
        .rst   (rst),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .din   (din),
        .dout  (dout),
        .full  (full),
        .empty (empty)
    );

    // -------------------------------------------------------------------------
    // 100 MHz Clock Generation (50% Duty Cycle)
    // -------------------------------------------------------------------------
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // Testbench Tasks
    // -------------------------------------------------------------------------

    // Task: Apply Synchronous Reset
    task apply_reset;
        begin
            @(posedge clk);
            rst = 1'b1;
            wr_en = 1'b0;
            rd_en = 1'b0;
            din   = {DATA_WIDTH{1'b0}};
            q_wr_idx = 0;
            q_rd_idx = 0;
            q_count  = 0;
            repeat (3) @(posedge clk);
            rst = 1'b0;
            @(posedge clk);
            $display("[TB-RESET] Reset sequence completed successfully.");
        end
    endtask

    // Task: Write a Single Data Byte into FIFO
    task write_byte(input [DATA_WIDTH-1:0] data_in);
        begin
            @(posedge clk);
            wr_en = 1'b1;
            din   = data_in;
            
            // If FIFO is not full, update golden queue
            if (!full) begin
                golden_queue[q_wr_idx] = data_in;
                q_wr_idx = q_wr_idx + 1;
                q_count  = q_count + 1;
            end
            
            @(posedge clk);
            wr_en = 1'b0;
            din   = {DATA_WIDTH{1'b0}};
        end
    endtask

    // Task: Read a Single Data Byte and Compare Against Golden Queue
    task read_and_check;
        reg [DATA_WIDTH-1:0] expected_val;
        begin
            @(posedge clk);
            rd_en = 1'b1;

            if (empty) begin
                $display("[TB-WARN] Attempted read when FIFO is empty at time %0t ps", $time);
                @(posedge clk);
                rd_en = 1'b0;
            end else begin
                expected_val = golden_queue[q_rd_idx];
                q_rd_idx = q_rd_idx + 1;
                q_count  = q_count - 1;

                @(posedge clk);
                rd_en = 1'b0;
                total_tests = total_tests + 1;

                // With synchronous read, dout holds the data after this posedge
                if (dout === expected_val) begin
                    $display("  [PASS] Read Data Match: Expected=0x%02X, Actual=0x%02X at time %0t ps", 
                             expected_val, dout, $time);
                    passed_tests = passed_tests + 1;
                end else begin
                    $display("  [FAIL] Data Mismatch! Expected=0x%02X, Actual=0x%02X at time %0t ps", 
                             expected_val, dout, $time);
                    failed_tests = failed_tests + 1;
                end
            end
        end
    endtask

    // Task: Assert Flag Condition
    task check_flags(input exp_empty, input exp_full, input [127:0] test_name);
        begin
            total_tests = total_tests + 1;
            if ((empty === exp_empty) && (full === exp_full)) begin
                $display("  [PASS] Flag Check [%0s]: Empty=%b (exp %b), Full=%b (exp %b)",
                         test_name, empty, exp_empty, full, exp_full);
                passed_tests = passed_tests + 1;
            end else begin
                $display("  [FAIL] Flag Check [%0s]: Empty=%b (exp %b), Full=%b (exp %b)",
                         test_name, empty, exp_empty, full, exp_full);
                failed_tests = failed_tests + 1;
            end
        end
    endtask

    // -------------------------------------------------------------------------
    // Main Verification Process
    // -------------------------------------------------------------------------
    initial begin
        // Configure Waveform Dump for Vivado XSIM / GTKWave
        $dumpfile("fifo_waveform.vcd");
        $dumpvars(0, fifo_tb);

        // Initialize Statistics
        total_tests  = 0;
        passed_tests = 0;
        failed_tests = 0;

        $display("==================================================================");
        $display("   SYNCHRONOUS FIFO MEMORY DESIGN - COMPREHENSIVE VERIFICATION   ");
        $display("   Specifications: 8-bit Data Width, 16-word Depth, Single Clock ");
        $display("==================================================================");

        // ---------------------------------------------------------------------
        // TEST 1: Synchronous Reset Verification
        // ---------------------------------------------------------------------
        $display("\n[TEST 1] Verifying Synchronous Reset Operation...");
        apply_reset();
        check_flags(1'b1, 1'b0, "Post-Reset Flags");
        if (dout === 8'h00) begin
            $display("  [PASS] Output Data correctly cleared to 0x00 on reset.");
            passed_tests = passed_tests + 1;
        end else begin
            $display("  [FAIL] Output Data not cleared on reset: 0x%02X", dout);
            failed_tests = failed_tests + 1;
        end
        total_tests = total_tests + 1;

        // ---------------------------------------------------------------------
        // TEST 2: Single Write and Single Read
        // ---------------------------------------------------------------------
        $display("\n[TEST 2] Verifying Single Write and Single Read...");
        write_byte(8'hA5);
        check_flags(1'b0, 1'b0, "After Single Write");
        read_and_check();
        check_flags(1'b1, 1'b0, "After Single Read (Empty)");

        // ---------------------------------------------------------------------
        // TEST 3: Multiple Write Operations (Burst Write of 8 bytes)
        // ---------------------------------------------------------------------
        $display("\n[TEST 3] Verifying Multiple Write Operations (8 Bytes)...");
        for (i = 0; i < 8; i = i + 1) begin
            write_byte(8'h10 + i);
        end
        check_flags(1'b0, 1'b0, "After 8 Writes (Half Full)");

        // ---------------------------------------------------------------------
        // TEST 4: Multiple Read Operations (Burst Read of 8 bytes)
        // ---------------------------------------------------------------------
        $display("\n[TEST 4] Verifying Multiple Read Operations (8 Bytes)...");
        for (i = 0; i < 8; i = i + 1) begin
            read_and_check();
        end
        check_flags(1'b1, 1'b0, "After Reading 8 Bytes (Empty)");

        // ---------------------------------------------------------------------
        // TEST 5: FIFO Full Condition Verification (16 Writes)
        // ---------------------------------------------------------------------
        $display("\n[TEST 5] Verifying FIFO Full Condition (Writing 16 Bytes)...");
        for (i = 0; i < DEPTH; i = i + 1) begin
            write_byte(8'h50 + i);
        end
        check_flags(1'b0, 1'b1, "FIFO Completely Full");

        // ---------------------------------------------------------------------
        // TEST 6: Overflow Prevention Verification
        // ---------------------------------------------------------------------
        $display("\n[TEST 6] Verifying Overflow Prevention Logic...");
        $display("  Attempting 3 additional writes when FIFO is full (0xFE, 0xFD, 0xFC)...");
        write_byte(8'hFE);
        write_byte(8'hFD);
        write_byte(8'hFC);
        check_flags(1'b0, 1'b1, "Full Flag Maintained Under Overflow Attempts");

        // ---------------------------------------------------------------------
        // TEST 7: FIFO Empty Condition Verification (16 Reads)
        // ---------------------------------------------------------------------
        $display("\n[TEST 7] Verifying FIFO Empty Condition (Reading 16 Bytes)...");
        for (i = 0; i < DEPTH; i = i + 1) begin
            read_and_check();
        end
        check_flags(1'b1, 1'b0, "FIFO Completely Empty");

        // ---------------------------------------------------------------------
        // TEST 8: Underflow Prevention Verification
        // ---------------------------------------------------------------------
        $display("\n[TEST 8] Verifying Underflow Prevention Logic...");
        $display("  Attempting 3 additional reads when FIFO is empty...");
        @(posedge clk);
        rd_en = 1'b1;
        repeat (3) @(posedge clk);
        rd_en = 1'b0;
        check_flags(1'b1, 1'b0, "Empty Flag Maintained Under Underflow Attempts");

        // ---------------------------------------------------------------------
        // TEST 9: Simultaneous Read and Write Operations
        // ---------------------------------------------------------------------
        $display("\n[TEST 9] Verifying Simultaneous Read and Write Operations...");
        // First preload 4 words into FIFO
        for (i = 0; i < 4; i = i + 1) begin
            write_byte(8'hA0 + i);
        end
        
        $display("  Executing 8 cycles of concurrent read and write...");
        for (i = 0; i < 8; i = i + 1) begin
            @(posedge clk);
            wr_en = 1'b1;
            rd_en = 1'b1;
            din   = 8'hB0 + i;
            
            // Track golden queue
            golden_queue[q_wr_idx] = 8'hB0 + i;
            q_wr_idx = q_wr_idx + 1;
            
            @(posedge clk);
            wr_en = 1'b0;
            rd_en = 1'b0;
            din   = 8'h00;
            
            // Check read data from the simultaneous read
            total_tests = total_tests + 1;
            if (dout === golden_queue[q_rd_idx]) begin
                $display("  [PASS] Simultaneous Cycle %0d: Read 0x%02X correctly matched expected.", 
                         i, dout);
                passed_tests = passed_tests + 1;
            end else begin
                $display("  [FAIL] Simultaneous Cycle %0d: Read 0x%02X != Expected 0x%02X", 
                         i, dout, golden_queue[q_rd_idx]);
                failed_tests = failed_tests + 1;
            end
            q_rd_idx = q_rd_idx + 1;
        end

        // Empty out remaining items
        while (empty == 1'b0) begin
            read_and_check();
        end

        // ---------------------------------------------------------------------
        // TEST 10: Pointer Wraparound Verification
        // ---------------------------------------------------------------------
        $display("\n[TEST 10] Verifying Pointer Wraparound (Crossing Depth Boundary Multiple Times)...");
        // Perform 25 cycles of write-2, read-2 to cycle pointers beyond 16 locations
        for (i = 0; i < 20; i = i + 1) begin
            write_byte(8'hC0 + (i % 16));
            write_byte(8'hD0 + (i % 16));
            read_and_check();
            read_and_check();
        end
        
        // Drain any remaining items
        while (empty == 1'b0) begin
            read_and_check();
        end
        check_flags(1'b1, 1'b0, "Flags After Multiple Wraparound Cycles");

        // ---------------------------------------------------------------------
        // Simulation Summary & Scoreboard Report
        // ---------------------------------------------------------------------
        #(CLK_PERIOD * 5);
        $display("\n==================================================================");
        $display("                   VERIFICATION SUMMARY REPORT                    ");
        $display("==================================================================");
        $display("  Total Checks Executed : %0d", total_tests);
        $display("  Checks PASSED         : %0d", passed_tests);
        $display("  Checks FAILED         : %0d", failed_tests);
        $display("------------------------------------------------------------------");
        if (failed_tests == 0 && total_tests > 0) begin
            $display("  RESULT: *** ALL VERIFICATION TESTS PASSED SUCCESSFULLY! ***    ");
        end else begin
            $display("  RESULT: *** TESTBENCH FAILED WITH %0d ERRORS ***              ", failed_tests);
        end
        $display("==================================================================\n");

        $finish;
    end

endmodule
