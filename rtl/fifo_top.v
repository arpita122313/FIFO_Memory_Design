// =============================================================================
// Project       : Synchronous FIFO Memory Design
// Module        : fifo_top
// File          : fifo_top.v
// Description   : Top-Level Synchronous FIFO Module integrating memory array,
//                 write pointer, read pointer, control logic, and status flags.
// Standard      : IEEE 1364-2001 (Verilog-2001)
// Synthesis     : Synthesizable (Targeted for Xilinx Vivado / 7-series FPGA)
// =============================================================================

`timescale 1ns / 1ps

module fifo_top #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk,       // System clock
    input  wire                  rst,       // Synchronous active-high reset
    input  wire                  wr_en,     // Write enable request
    input  wire                  rd_en,     // Read enable request
    input  wire [DATA_WIDTH-1:0] din,       // 8-bit input data to write
    output wire [DATA_WIDTH-1:0] dout,      // 8-bit registered output data read
    output wire                  full,      // FIFO full status flag
    output wire                  empty      // FIFO empty status flag
);

    // -------------------------------------------------------------------------
    // Local Parameters
    // -------------------------------------------------------------------------
    localparam POINTER_WIDTH = ADDR_WIDTH + 1; // 5 bits for 16-word depth

    // -------------------------------------------------------------------------
    // Internal Interconnect Wires
    // -------------------------------------------------------------------------
    wire                     wr_valid;      // Qualified write enable
    wire                     rd_valid;      // Qualified read enable
    wire [ADDR_WIDTH-1:0]    wr_addr;       // 4-bit memory write address
    wire [ADDR_WIDTH-1:0]    rd_addr;       // 4-bit memory read address
    wire [POINTER_WIDTH-1:0] wr_ptr;        // 5-bit write pointer
    wire [POINTER_WIDTH-1:0] rd_ptr;        // 5-bit read pointer
    wire [POINTER_WIDTH-1:0] fifo_cnt;      // Current FIFO occupancy

    // -------------------------------------------------------------------------
    // 1. FIFO Control Logic: Gating for Overflow and Underflow Protection
    // -------------------------------------------------------------------------
    fifo_control u_fifo_control (
        .wr_en    (wr_en),
        .rd_en    (rd_en),
        .full     (full),
        .empty    (empty),
        .wr_valid (wr_valid),
        .rd_valid (rd_valid)
    );

    // -------------------------------------------------------------------------
    // 2. Write Pointer Logic: 5-bit synchronous counter
    // -------------------------------------------------------------------------
    write_pointer #(
        .ADDR_WIDTH    (ADDR_WIDTH),
        .POINTER_WIDTH (POINTER_WIDTH)
    ) u_write_pointer (
        .clk      (clk),
        .rst      (rst),
        .wr_valid (wr_valid),
        .wr_ptr   (wr_ptr),
        .wr_addr  (wr_addr)
    );

    // -------------------------------------------------------------------------
    // 3. Read Pointer Logic: 5-bit synchronous counter
    // -------------------------------------------------------------------------
    read_pointer #(
        .ADDR_WIDTH    (ADDR_WIDTH),
        .POINTER_WIDTH (POINTER_WIDTH)
    ) u_read_pointer (
        .clk      (clk),
        .rst      (rst),
        .rd_valid (rd_valid),
        .rd_ptr   (rd_ptr),
        .rd_addr  (rd_addr)
    );

    // -------------------------------------------------------------------------
    // 4. Status Flag Logic: (N+1)-bit pointer wraparound comparison
    // -------------------------------------------------------------------------
    fifo_status #(
        .ADDR_WIDTH    (ADDR_WIDTH),
        .POINTER_WIDTH (POINTER_WIDTH)
    ) u_fifo_status (
        .wr_ptr   (wr_ptr),
        .rd_ptr   (rd_ptr),
        .full     (full),
        .empty    (empty),
        .fifo_cnt (fifo_cnt)
    );

    // -------------------------------------------------------------------------
    // 5. Dual-Port Memory Array: 16 locations x 8-bit registers
    // -------------------------------------------------------------------------
    fifo_mem #(
        .DATA_WIDTH (DATA_WIDTH),
        .DEPTH      (DEPTH),
        .ADDR_WIDTH (ADDR_WIDTH)
    ) u_fifo_mem (
        .clk      (clk),
        .rst      (rst),
        .wr_valid (wr_valid),
        .rd_valid (rd_valid),
        .wr_addr  (wr_addr),
        .rd_addr  (rd_addr),
        .din      (din),
        .dout     (dout)
    );

endmodule
