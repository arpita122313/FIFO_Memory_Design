// =============================================================================
// Project       : Synchronous FIFO Memory Design
// Module        : fifo_status
// File          : fifo_status.v
// Description   : Full and Empty Flag Generation using (N+1)-bit Pointer Comparison
// Standard      : IEEE 1364-2001 (Verilog-2001)
// Synthesis     : Synthesizable (Efficient comparator logic)
// =============================================================================

`timescale 1ns / 1ps

module fifo_status #(
    parameter ADDR_WIDTH    = 4,
    parameter POINTER_WIDTH = ADDR_WIDTH + 1
)(
    input  wire [POINTER_WIDTH-1:0] wr_ptr,    // 5-bit write pointer
    input  wire [POINTER_WIDTH-1:0] rd_ptr,    // 5-bit read pointer
    output wire                     full,      // FIFO full flag
    output wire                     empty,     // FIFO empty flag
    output wire [POINTER_WIDTH-1:0] fifo_cnt   // Current number of words stored (0 to 16)
);

    // -------------------------------------------------------------------------
    // Empty Flag Generation:
    // Asserted when write pointer and read pointer are identical in all bits,
    // indicating that all written data has been consumed.
    // -------------------------------------------------------------------------
    assign empty = (wr_ptr == rd_ptr);

    // -------------------------------------------------------------------------
    // Full Flag Generation:
    // Asserted when:
    // 1. The MSB (wrap bit) differs: wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]
    // 2. The lower memory address bits match: wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]
    // This indicates the write pointer has wrapped around exactly one full buffer.
    // -------------------------------------------------------------------------
    assign full  = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
                   (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

    // -------------------------------------------------------------------------
    // FIFO Occupancy Counter:
    // Computes difference between write pointer and read pointer.
    // Range: 0 (empty) to 16 (full for DEPTH=16).
    // -------------------------------------------------------------------------
    assign fifo_cnt = wr_ptr - rd_ptr;

endmodule
