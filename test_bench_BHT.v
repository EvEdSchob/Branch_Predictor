`timescale 1ns / 1ps

module BHT_testbench();

    reg clk, reset;
    reg [9:0] pc_temp; // Temporary 10-bit register to read the full PC value
    reg [8:0] pc; // 9-bit PC for the simulation
    reg taken;
    wire prediction;
    integer file, r;
    integer total_predictions = 0;
    integer correct_predictions = 0;
    localparam M = 64; 
    localparam N = 2;

    // Instantiate the BHT module
    BHT #(
        .M(M), 
        .N(N)   
    ) bht_test_bench (
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
            // Read the PC value as hexadecimal
            r = $fscanf(file, "%x\n", pc_temp);
            if (r != 1) begin
                $display("Failed to read a PC value. Terminating simulation.");
                $fclose(file);
                $finish;
            end
            // Read the taken flag
            r = $fscanf(file, "%d\n", taken);
            if (r != 1) begin
                $display("Failed to read a taken flag. Terminating simulation.");
                $fclose(file);
                $finish;
            end
            
            // Least significant 9 bits for the simulation
            pc = pc_temp[8:0];
            $display("Read PC: %x (9 bits: %b), Taken: %b", pc_temp, pc, taken); // Debugging output
            
            
           // @(posedge clk);
            @(posedge clk);
            total_predictions = total_predictions + 1;
            if (prediction == taken) begin
                correct_predictions = correct_predictions + 1;
            end
           
        end
        
        // Simulation and file closure
        $fclose(file);
        $display("Total Predictions: %d, Correct Predictions: %d", total_predictions, correct_predictions);
        $finish;
    end

endmodule
