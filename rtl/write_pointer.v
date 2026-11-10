// =============================================================================
// Project       : Synchronous FIFO Memory Design
// Module        : write_pointer
// File          : write_pointer.v
// Description   : 5-bit Write Pointer Logic with synchronous reset and overflow gating
// Standard      : IEEE 1364-2001 (Verilog-2001)
// Synthesis     : Synthesizable (Clean synchronous counter)
// =============================================================================

`timescale 1ns / 1ps

module write_pointer #(
    parameter ADDR_WIDTH    = 4,
    parameter POINTER_WIDTH = ADDR_WIDTH + 1
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     wr_valid,  // Asserted when wr_en && !full
    output reg  [POINTER_WIDTH-1:0] wr_ptr,    // 5-bit write pointer (MSB for wrap detection)
    output wire [ADDR_WIDTH-1:0]    wr_addr    // 4-bit memory write address
);

    // Memory address is the lower ADDR_WIDTH bits of the pointer
    assign wr_addr = wr_ptr[ADDR_WIDTH-1:0];

    // Synchronous pointer increment on valid write operation
    always @(posedge clk) begin
        if (rst) begin
            wr_ptr <= {POINTER_WIDTH{1'b0}};
        end else if (wr_valid) begin
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

endmodule
