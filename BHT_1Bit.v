`timescale 1ns / 1ps

module BHT(
    input wire clk,
    input wire reset,
    input wire [8:0] pc,  
    input wire taken,
    output wire prediction
 
);
    parameter M = 64; // Change in TB
    parameter N = 2;  // change in TB

    // Local parameters for addressing
    localparam ADDR_BITS = $clog2(M);

    // Index calculation using lower bits of PC
    wire [ADDR_BITS-1:0] index = pc[ADDR_BITS-1:0];

    // Prediction output wire for each predictor instance
    wire [M-1:0] predictions;

    // Generate function to connect the right module referring to the selection N
    generate
        if (N == 1) begin
            // Instantiate M 1-bit predictors
            genvar i;
            for (i = 0; i < M; i = i + 1) begin : gen_bp_1bit
                BP_1Bit bp1 (
                    .clk(clk),
                    .rst(reset),
                    .result(taken),
                    .predict(predictions[i])
                );
            end
        end 
        else if (N == 2) begin
            // Instantiate M 2-bit predictors
            genvar i;
            for (i = 0; i < M; i = i + 1) begin : gen_bp_2bit
                BP_2Bit bp2 (
                    .clk(clk),
                    .rst(reset),
                    .result(taken),
                    .predict(predictions[i])
                );
            end
        end
    endgenerate

    // Select the prediction based on the indexed predictor
    assign prediction = predictions[index];


endmodule
