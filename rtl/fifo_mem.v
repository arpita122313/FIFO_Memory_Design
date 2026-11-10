// =============================================================================
// Project       : Synchronous FIFO Memory Design
// Module        : fifo_mem
// File          : fifo_mem.v
// Description   : Dual-port Synchronous Memory Array (16 locations x 8-bit data)
// Standard      : IEEE 1364-2001 (Verilog-2001)
// Synthesis     : Synthesizable (Infers LUTRAM/Distributed RAM on Xilinx 7-series)
// =============================================================================

`timescale 1ns / 1ps

module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_valid,      // Qualified write enable (wr_en && !full)
    input  wire                  rd_valid,      // Qualified read enable (rd_en && !empty)
    input  wire [ADDR_WIDTH-1:0] wr_addr,       // 4-bit write address from write pointer
    input  wire [ADDR_WIDTH-1:0] rd_addr,       // 4-bit read address from read pointer
    input  wire [DATA_WIDTH-1:0] din,           // 8-bit input data
    output reg  [DATA_WIDTH-1:0] dout           // 8-bit registered output data
);

    // -------------------------------------------------------------------------
    // Memory Array Declaration: 16 locations, 8 bits per location
    // -------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [DEPTH-1:0];

    // -------------------------------------------------------------------------
    // Synchronous Write Operation
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (wr_valid) begin
            mem[wr_addr] <= din;
        end
    end

    // -------------------------------------------------------------------------
    // Synchronous Read Operation with Synchronous Reset
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            dout <= {DATA_WIDTH{1'b0}};
        end else if (rd_valid) begin
            dout <= mem[rd_addr];
        end
        // When rd_valid is low, dout maintains its previous valid read data
    end

endmodule
