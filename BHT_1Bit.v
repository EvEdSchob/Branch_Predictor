`timescale 1ns / 1ps

module BHT(
    input wire clk,
    input wire reset,
    input wire [8:0] pc,
    input wire taken,
    output wire prediction
);

parameter M = 16; // Change in TB
parameter N = 1;  // Change in TB


    function integer m_function;
        input integer value;
        begin
            m_function = 0;
            value = value - 1; 
            while (value > 0) begin
                m_function = m_function + 1;
                value = value >> 1;
            end
        end
    endfunction

// Local parameters for addressing
localparam ADDR_BITS = m_function(M);

// Index calculation using lower bits of PC
wire [ADDR_BITS-1:0] index = pc[ADDR_BITS-1:0];
wire [M-1:0] EN_Vec;
assign EN_Vec = 1 << index;
// Prediction output wire for each predictor instance
wire [M-1:0] predictions;

    if (N == 1) begin
    BP_1Bit bp1_M_instances[M-1:0] (
        .clk(clk),
        .rst(reset),
        .result(taken),
        .predict(predictions[M-1:0]),
        .en(EN_Vec[M-1:0])
    );
end else if (N == 2) begin
    BP_2Bit bp2_M_instances[M-1:0] (
        .clk(clk),
        .rst(reset),
        .result(taken),
        .predict(predictions[M-1:0]),
        .en(EN_Vec[M-1:0])
    );
end

    // Select the prediction based on the indexed predictor
    assign prediction = predictions[index];


endmodule
