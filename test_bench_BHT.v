`timescale 1ns / 1ps

module BHT_testbench();

    reg clk, reset;
    reg [8:0] pc;
    reg taken;
    wire prediction;
    integer file, r;
    integer total_predictions = 0;
    integer correct_predictions = 0;
    
    // Instantiate the BHT module
    BHT #(
        .M(16), // Adjust M as necessary
        .N(2)   // Using 2-bit predictors for this example
    ) bht_instance (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .taken(taken),
        .prediction(prediction)
    );
    
    // Generate clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with a period of 10ns
    end
    
    // Test sequence
    initial begin
        // Initialize
        reset = 1;
        #20;
        reset = 0;
        
        // Open the file containing the PC values and taken flags
        file = $fopen("out2.txt", "r");
        if (file == 0) begin
            $display("Error: Failed to open file.");
            $finish;
        end
        
        // Read from the file and apply each test case
        while (!$feof(file)) begin
            r = $fscanf(file, "%d\n%d\n", pc, taken);
            if (r != 2) begin
                $display("Warning: Unexpected end of file or format error.");
                // Close the file and end the simulation if format is not as expected
                $fclose(file);
                $finish;
            end
            
            $display("Read PC: %d, Taken: %d", pc, taken); // Debugging output
            
            // Wait for the next clock cycle to ensure the inputs are properly sampled
            @(posedge clk);
            
            // Wait for the prediction to be stable (next cycle after taken is applied)
            @(posedge clk);
            total_predictions = total_predictions + 1;
            if (prediction === taken) begin
                correct_predictions = correct_predictions + 1;
            end
            
            // Additional delay to observe changes, if necessary
            #10;
        end
        
        // Simulation and file closure
        $fclose(file);
        $display("Total Predictions: %d, Correct Predictions: %d", total_predictions, correct_predictions);
        $finish;
    end

endmodule
