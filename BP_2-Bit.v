`timescale 1ns / 1ps

module BP_2Bit(
    input wire clk, rst, en,
    input wire result, //Taken = 1, Not Taken = 0
    output reg predict //Taken = 1, Not Taken = 0
    );
    
    parameter s1 = 2'b00;
    parameter s2 = 2'b01;
    parameter s3 = 2'b10;
    parameter s4 = 2'b11;
    
    reg [1:0] present_state, next_state;
    
    always @(present_state, result)
    begin
            case(present_state)
            s1: //Strongly taken
            begin
                if(result)
                    next_state = s1; //Stay in state 1 (Strongly Taken)
                else
                    next_state = s2; //Move to state 2 (Weakly Taken)
            end
            s2: //Weakly taken
            begin
                if(result)
                    next_state = s1; //Move to state 1 (Strongly Taken)
                else
                    next_state = s3; //Move to state 3 (Weakly Not Taken)
            end
            s3: //Weakly not taken
            begin
                if(result)
                    next_state = s2; //Move to state 2 (Weakly Taken)
                else
                    next_state = s4; //Move to state 4 (Strongly Not Taken) 
            end
            s4: //Strongly not taken
            begin
                if(result)
                    next_state = s4; //Stay in state 4 (Strongly Not Taken)
                else
                    next_state = s3; //Move to state 3 (Weakly Not Taken)
            end
            default: next_state = s1;
            endcase     
    end
    always @ (posedge clk)
    begin
        if (present_state == s4)
            predict = 0;
        else if (present_state == s3)
            predict = 0;
        else if (present_state == s2)
            predict = 1;
        else
            predict = 1; 
    end
    
    always @ (posedge clk, posedge rst)
    begin
        if (rst == 1'b1)
            present_state = s1;
        else if(en == 1'b1)
            present_state = next_state;
    end
endmodule