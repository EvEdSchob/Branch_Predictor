`timescale 1ns / 1ps

module BP_1Bit(
    input wire clk, rst, en,
    input wire result, //Taken = 1, Not Taken = 0
    output reg predict //Taken = 1, Not Taken = 0
    );
    
    parameter s1 = 1'b0;
    parameter s2 = 1'b1;
    
    reg [1:0] present_state, next_state;
    
    always @(present_state, result)
    begin
        case(present_state)
        s1: //Predict taken
        begin
            predict = 1;
            if(result)
                next_state = s1; //Stay in taken
            else
                next_state = s2; //Move to not taken
        end
        s2: //Predict not taken
        begin
            predict = 0;
            if(result)
                next_state = s1; //Move to taken
            else
                next_state = s2; //Stay in not taken
        end
        default: next_state = s1;
        endcase
    end
    always @ (posedge clk)
    begin
        if(present_state == s2)
            predict = 0;
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
