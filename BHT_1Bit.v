`timescale 1ns / 1ps

module BHT(
    input wire clk,
    input wire reset,
    input wire [8:0] pc,  
    input wire taken,     // Branch outcome: taken or not taken
    output wire prediction // Predicted branch outcome, changed to reg to allow procedural assignment
);
    reg prediction_internal;
    parameter M = 16; // Number of entries in the BHT
    parameter N = 1;  // Number of bits per entry (1 for 1-bit, 2 for 2-bit predictor)

// Local parameters
localparam ADDR_BITS = $clog2(M);  // Number of bits needed to address M entries

// BHT memory
reg [N-1:0] bht [M-1:0];

// Addressing
wire [ADDR_BITS-1:0] index = pc[ADDR_BITS-1:0]; // Use lower bits of PC to address BHT

assign prediction = prediction_internal;

// Initialize BHT
integer i;
always @(posedge reset) begin
    for (i = 0; i < M; i = i + 1) begin
        bht[i] <= 0;
    end
end

generate
    if (N == 1) begin : gen_bp_1bit
        BP_1Bit bp1 (
            .clk(clk),
            .rst(reset), // Adjusted to match signal name
            .result(taken), 
            .predict(prediction) // Directly connect the output to the BHT prediction output
        );
    end else if (N == 2) begin : gen_bp_2bit
        BP_2Bit bp2 (
            .clk(clk),
            .rst(reset), 
            .result(taken), 
            .predict(prediction) // Directly connect the output to the BHT prediction output
        );
    end
endgenerate


endmodule
