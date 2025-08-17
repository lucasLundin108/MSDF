`timescale 1ns/1ps
`include "Bit_rep.vh"

module tb_top();
    parameter N = 8;
    parameter CLK_PERIOD = 10;
    
    reg [1:0] x_values [0:7];
    reg [1:0] xj_plus_4;
    reg [N:0] Y;
    
    reg clk;
    reg rst;
    reg start;

    integer i;

    reg load_CA_REG_Y;

    wire [1:0] Zj;
    wire ready_Zj;


    
    top #(
        .N(N)
    ) dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .Y(Y),
        .load_CA_REG_Y(load_CA_REG_Y),
        .xj_plus_4(xj_plus_4),
        .Zj(Zj),
        .ready_Zj(ready_Zj)
    );



    
    always begin
        clk = 1'b0;
        #(CLK_PERIOD/2);
        clk = 1'b1;
        #(CLK_PERIOD/2);
    end
    
    initial begin
        x_values[0] = `R2_POS_ONE;
        x_values[1] = `R2_POS_ONE;
        x_values[2] = `R2_ZERO;
        x_values[3] = `R2_NEG_ONE;
        x_values[4] = `R2_POS_ONE;
        x_values[5] = `R2_ZERO;
        x_values[6] = `R2_NEG_ONE;
        x_values[7] = `R2_POS_ONE;
        
        // y_values[0] = `R2_POS_ONE;
        // y_values[1] = `R2_ZERO;
        // y_values[2] = `R2_POS_ONE;
        // y_values[3] = `R2_NEG_ONE;
        // y_values[4] = `R2_NEG_ONE;
        // y_values[5] = `R2_POS_ONE;
        // y_values[6] = `R2_POS_ONE;
        // y_values[7] = `R2_ZERO;
        Y = 9'b010001110;

        


        // x_values[0] = `R2_POS_ONE;
        // x_values[1] = `R2_POS_ONE;
        // x_values[2] = `R2_NEG_ONE;
        // x_values[3] = `R2_ZERO;
        // x_values[4] = `R2_POS_ONE;
        // x_values[5] = `R2_NEG_ONE;
        // x_values[6] = `R2_ZERO;
        // x_values[7] = `R2_POS_ONE;
        

        // y_values[0] = `R2_POS_ONE;
        // y_values[1] = `R2_ZERO;
        // y_values[2] = `R2_POS_ONE;
        // y_values[3] = `R2_NEG_ONE;
        // y_values[4] = `R2_NEG_ONE;
        // y_values[5] = `R2_POS_ONE;
        // y_values[6] = `R2_POS_ONE;
        // y_values[7] = `R2_ZERO;
        // Y = 9'b010001110;


        xj_plus_4 = `R2_ZERO;

        rst = 1'b0;
        #(CLK_PERIOD*2);
        
        rst = 1'b1;
        load_CA_REG_Y = 1;
        
        #(CLK_PERIOD);
        start = 1;
        #(CLK_PERIOD);
        start = 0;

        
        for (i = 0; i <= N+4; i = i + 1) begin
            $display("Time %0t: Loading x[%0d] = %b, y[%0d] = %b",  $time, i, x_values[i], i, Y);
            
            if(i >= N)begin
                xj_plus_4 = `R2_ZERO;
            end else begin
                xj_plus_4 = x_values[i];
            end
            #(CLK_PERIOD);
        end        
        #(CLK_PERIOD*2);
        $display("Simulation completed");
        $finish;
    end
endmodule