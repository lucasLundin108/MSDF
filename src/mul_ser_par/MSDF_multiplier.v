module top #(
    parameter N = 9
)(
    input clk,
    input rst,
    input start,
    input [N:0] Y,
    input load_CA_REG_Y,
    input [1:0] xj_plus_4,
    output [1:0] Zj,
    output ready_Zj
);
    wire load_REG_WC;
    wire load_REG_WS;
    wire load_PJ;
    

    controller #(
        .N(N)
    ) ctrl (
        .clk(clk),
        .rst(rst),
        .start(start),
        .load_REG_WC(load_REG_WC),
        .load_REG_WS(load_REG_WS),
        .load_PJ(load_PJ),
        .ready_Zj(ready_Zj)
    );



    datapath #(
        .N(N)
    ) dp (
        .clk(clk),
        .rst(rst),
        .Y(Y),
        .xj_plus_4(xj_plus_4),
        .load_CA_REG_Y(load_CA_REG_Y),
        .load_REG_WC(load_REG_WC),
        .load_REG_WS(load_REG_WS),
        .load_PJ(load_PJ),
        .Zj(Zj)
    );
endmodule