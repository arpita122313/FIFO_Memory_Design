// =============================================================================
// Project       : Synchronous FIFO Memory Design
// Module        : read_pointer
// File          : read_pointer.v
// Description   : 5-bit Read Pointer Logic with synchronous reset and underflow gating
// Standard      : IEEE 1364-2001 (Verilog-2001)
// Synthesis     : Synthesizable (Clean synchronous counter)
// =============================================================================

`timescale 1ns / 1ps

module read_pointer #(
    parameter ADDR_WIDTH    = 4,
    parameter POINTER_WIDTH = ADDR_WIDTH + 1
)(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     rd_valid,  // Asserted when rd_en && !empty
    output reg  [POINTER_WIDTH-1:0] rd_ptr,    // 5-bit read pointer (MSB for wrap detection)
    output wire [ADDR_WIDTH-1:0]    rd_addr    // 4-bit memory read address
);

    // Memory address is the lower ADDR_WIDTH bits of the pointer
    assign rd_addr = rd_ptr[ADDR_WIDTH-1:0];

    // Synchronous pointer increment on valid read operation
    always @(posedge clk) begin
        if (rst) begin
            rd_ptr <= {POINTER_WIDTH{1'b0}};
        end else if (rd_valid) begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end

endmodule
