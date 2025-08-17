module top #(
    parameter N = 9
)(
    input clk,
    input rst,
    input [1:0] xj_plus_5,
    input [1:0] yj_plus_5,
    output [1:0] Zj,
    output ready_Zj
);
    wire load_LX;
    wire load_LY;
    wire load_CA_REG_X;
    wire load_CA_REG_Y;
    wire load_REG_WC;
    wire load_REG_WS;
    wire load_PJ;
    

    controller #(
        .N(N)
    ) ctrl (
        .clk(clk),
        .rst(rst),
        .load_LX(load_LX),
        .load_LY(load_LY),
        .load_CA_REG_X(load_CA_REG_X),
        .load_CA_REG_Y(load_CA_REG_Y),
        .load_REG_WC(load_REG_WC),
        .load_REG_WS(load_REG_WS),
        .load_PJ(load_PJ),
        .ready_Zj(ready_Zj)
    );

    datapath #(
        .N(N+1)
    ) dp (
        .clk(clk),
        .rst(rst),
        .xj_plus_5(xj_plus_5),
        .yj_plus_5(yj_plus_5),
        .load_LX(load_LX),
        .load_LY(load_LY),
        .load_CA_REG_X(load_CA_REG_X),
        .load_CA_REG_Y(load_CA_REG_Y),
        .load_REG_WC(load_REG_WC),
        .load_REG_WS(load_REG_WS),
        .load_PJ(load_PJ),
        .Zj(Zj)
    );
endmodule