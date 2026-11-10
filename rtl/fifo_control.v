// =============================================================================
// Project       : Synchronous FIFO Memory Design
// Module        : fifo_control
// File          : fifo_control.v
// Description   : FIFO Control Logic providing qualified write and read enables
//                 with built-in hardware overflow and underflow protection.
// Standard      : IEEE 1364-2001 (Verilog-2001)
// Synthesis     : Synthesizable (Pure combinational gating logic)
// =============================================================================

`timescale 1ns / 1ps

module fifo_control (
    input  wire wr_en,     // User write enable request
    input  wire rd_en,     // User read enable request
    input  wire full,      // FIFO full flag
    input  wire empty,     // FIFO empty flag
    output wire wr_valid,  // Qualified write: allowed only when NOT full
    output wire rd_valid   // Qualified read: allowed only when NOT empty
);

    // -------------------------------------------------------------------------
    // Overflow Prevention:
    // Disallow write operation and pointer advance if FIFO is full.
    // -------------------------------------------------------------------------
    assign wr_valid = wr_en & ~full;

    // -------------------------------------------------------------------------
    // Underflow Prevention:
    // Disallow read operation and pointer advance if FIFO is empty.
    // -------------------------------------------------------------------------
    assign rd_valid = rd_en & ~empty;

endmodule
