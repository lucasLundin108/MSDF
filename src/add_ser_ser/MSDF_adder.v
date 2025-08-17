module top #(
    parameter N = 9
)(
    input clk,
    input rst,
    input [1:0] xj_plus_3,
    input [1:0] yj_plus_3,
    output [1:0] Zj,
    output ready_Zj
);
    wire load_L_LEVEL1;
    wire load_L_LEVEL2;
    wire load_L_LEVEL3;

    

    controller #(
        .N(N)
    ) ctrl (
        .clk(clk),
        .rst(rst),
        .load_L_LEVEL1(load_L_LEVEL1),
        .load_L_LEVEL2(load_L_LEVEL2),
        .load_L_LEVEL3(load_L_LEVEL3),
        .ready_Zj(ready_Zj)
    );

    datapath #(
        .N(N)
    ) dp (
        .clk(clk),
        .rst(rst),
        .xj_plus_3(xj_plus_3),
        .yj_plus_3(yj_plus_3),
        .load_L_LEVEL1(load_L_LEVEL1),
        .load_L_LEVEL2(load_L_LEVEL2),
        .load_L_LEVEL3(load_L_LEVEL3),
        .Zj(Zj)
    );

endmodule