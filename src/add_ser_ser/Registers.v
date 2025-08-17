`include "Bit_rep.vh"

module CA_REG #(
    parameter REG_SIZE = 8 
) (
    input wire clk,
    input wire rst,
    input wire load,
    input wire signed [1:0] inp,
    output wire signed [REG_SIZE-1:0] orig_value,
    output wire signed [REG_SIZE-1:0] complete_value
);
    reg signed [REG_SIZE-1:0] value_reg;
    reg [$clog2(REG_SIZE)-1:0] counter; 

    assign orig_value = value_reg;
    assign complete_value = value_reg*(-1);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            value_reg <= {REG_SIZE{1'b0}};
            counter <= REG_SIZE-2;
        end
        else if (load) begin
            case (inp)
                `R2_NEG_ONE: value_reg <= value_reg - (1 << counter);
                `R2_POS_ONE: value_reg <= value_reg + (1 << counter);
                `R2_ZERO:    value_reg <= value_reg;
                default:     value_reg <= value_reg;
            endcase
            counter = counter - 1;
        end
    end
endmodule


module SELECTOR #(
    parameter N = 8
)(
    input  [1:0]        sel,
    input  [N-1:0]      X,
    input  [N-1:0]      X_COMP,
    output reg [N-1:0]  out
);
    always @(*) begin
        case (sel)
            `R2_ZERO:       out = {N{1'b0}};
            `R2_POS_ONE:    out = X;
            `R2_NEG_ONE:    out = X_COMP;
            default: out = X;
        endcase
    end
endmodule


module FA (
    input  a, b, cin,
    output sum, cout
);
    assign {cout, sum} = a + b + cin;
endmodule






module CSA_4_2 #(
    parameter N = 8
)(
    input  [N-1:0] X,
    input  [N-1:0] Y,
    input  [N+1:0] Z,
    input  [N+1:0] W,
    output [N+1:0] sum,
    output [N+1:0] carry
);

    wire [N+1:0] X_ext = {{2{X[N-1]}}, X};
    wire [N+1:0] Y_ext = {{2{Y[N-1]}}, Y};
    
    wire [N+1:0] sum_stage1;
    wire [N+1:0] carry_stage1;
    
    wire [N+1:0] sum_stage2;
    wire [N+1:0] carry_stage2;
    
    genvar i;
    generate
        for (i = 0; i < N+2; i = i + 1) begin : csa_stage1
            FA fa_stage1 (
                .a(X_ext[i]),
                .b(Y_ext[i]),
                .cin(Z[i]),
                .sum(sum_stage1[i]),
                .cout(carry_stage1[i])
            );
        end
    endgenerate
    
    generate
        for (i = 0; i < N+2; i = i + 1) begin : csa_stage2
            FA fa_stage2 (
                .a(sum_stage1[i]),
                .b(W[i]),
                .cin(i > 0 ? carry_stage1[i-1] : 1'b0),
                .sum(sum_stage2[i]),
                .cout(carry_stage2[i])
            );
        end
    endgenerate

    assign sum = sum_stage2;
    assign carry = {carry_stage2[N:0], 1'b0};

endmodule




module Adder #(
    parameter N = 8
) (
    input wire [N-1:0] A,
    input wire [N-1:0] B,
    output wire [N-1:0] Sum,
    output wire Overflow
);
    wire [N:0] SumExt;
    assign SumExt = {A[N-1], A} + {B[N-1], B};
    
    assign Sum = SumExt[N-1:0];
    
    assign Overflow = (~A[N-1] & ~B[N-1] & Sum[N-1]) |
                     (A[N-1] & B[N-1] & ~Sum[N-1]);

endmodule



module SEL_M (
    input  [3:0]        in,
    output reg [1:0]    out
);

    always @(*) begin
        case (in)
            4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111:   out = 2'b01;
            4'b0000, 4'b0001, 4'b1110, 4'b1111:                     out = 2'b00;
            4'b1000, 4'b1001, 4'b1010, 4'b1011,  4'b1100, 4'b1101:  out = 2'b11;
            default:                                                out = 2'b00;
        endcase
    end

endmodule


module register #(
    parameter N = 8
)(
    input              clk,
    input              rst,
    input              load,
    input      [N-1:0] d,
    output reg [N-1:0] q
);

    always @(posedge clk, negedge rst) begin
        if (!rst)
            q <= {N{1'b0}};
        else if (load)
            q <= d;
    end

endmodule


module subtractor #(
    parameter N = 8
) (
    input [N-1:0] X,
    input [N-1:0] Y,
    output [N-1:0] Z
);
    assign Z = X - Y;
endmodule



module tb_CA_REG;
    parameter REG_SIZE = 8;
    parameter CLK_PERIOD = 10;
    

    reg clk;
    reg rst;
    reg load;
    reg signed [1:0] inp;
    wire signed [REG_SIZE:0] orig_value;
    wire signed [REG_SIZE:0] complete_value;

    CA_REG #(
        .REG_SIZE(REG_SIZE+1)
    ) uut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .inp(inp),
        .orig_value(orig_value),
        .complete_value(complete_value)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $monitor("time=%0t rst=%b load=%b inp=%d value=%d complete_value=%d", 
                 $time, rst, load, inp, orig_value,complete_value);
                 

        rst = 0;
        load = 0;
        inp = `R2_ZERO;
        #20;

        rst = 1;
        #(2*CLK_PERIOD);

        load = 1;
        inp = `R2_POS_ONE;
        #(2*CLK_PERIOD);

        inp = `R2_ZERO;
        #(1*CLK_PERIOD);

        inp = `R2_NEG_ONE;
        #(1*CLK_PERIOD);

        inp = `R2_POS_ONE;
        #(1*CLK_PERIOD);

        inp = `R2_ZERO;
        #(1*CLK_PERIOD);

        inp = `R2_NEG_ONE;
        #(1*CLK_PERIOD);

        inp = `R2_POS_ONE;
        #(1*CLK_PERIOD);

        load = 0;
        inp = `R2_POS_ONE;
        #20;

        rst = 1;
        #20;

        $finish;
    end
endmodule




module tb_CSA_4_2;
    parameter N = 8;
    
    reg [N-1:0] X;
    reg [N-1:0] Y;
    reg [N+1:0] Z;
    reg [N+1:0] W;
    wire [N+1:0] sum;
    wire [N+1:0] carry;
    
    CSA_4_2 #(N) uut (X, Y, Z, W, sum, carry);
    
    initial begin
        X = 8'h00; Y = 8'h00; Z = 10'h000; W = 10'h000;
        #10;
        
        X = 8'hFF; Y = 8'h01; Z = 10'h000; W = 10'h000;
        #10;
        
        X = 8'h55; Y = 8'hAA; Z = 10'h3FF; W = 10'h155;
        #10;
        
        X = 8'h7F; Y = 8'h7F; Z = 10'h3FF; W = 10'h3FF;
        #10;
        
        X = 8'h80; Y = 8'h80; Z = 10'h3FF; W = 10'h3FF;
        #10;
        
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t X=%h Y=%h Z=%h W=%h Sum=%h Carry=%h", 
                 $time, X, Y, Z, W, sum, carry);
    end
endmodule