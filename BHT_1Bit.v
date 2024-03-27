`timescale 1ns / 1ps

module BHT(
    input wire clk,
    input wire reset,
    input wire [8:0] pc,  
    input wire taken,
    output wire prediction,
    output reg [31:0] total_predictions = 0, // Counts total predictions
    output reg [31:0] correct_predictions = 0 // Counts correct predictions
);
    parameter M = 0; // Number of entries in the BHT
    parameter N = 0;  // Number of bits per entry

    // Local parameters for addressing
    localparam ADDR_BITS = $clog2(M);

    // Index calculation using lower bits of PC
    wire [ADDR_BITS-1:0] index = pc[ADDR_BITS-1:0];

    // Prediction output wire for each predictor instance
    wire [M-1:0] predictions;

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
        end else if (N == 2) begin
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

    // Count total and correct predictions
    always @(posedge clk) begin
        if (!reset) begin
            total_predictions <= total_predictions + 1; // Increment total predictions every cycle

            // Compare the selected prediction to the actual outcome and update correct_predictions
            if (prediction == taken) begin
                correct_predictions <= correct_predictions + 1;
            end
        end else begin
            // Reset the counters on reset signal
            total_predictions <= 0;
            correct_predictions <= 0;
        end
    end

endmodule
