module datapath#(
    parameter N = 8
)(
    input               clk,
    input               rst,
    input [1:0]         xj_plus_5,
    input [1:0]         yj_plus_5,
    input               load_LX,
    input               load_LY,
    input               load_CA_REG_X,
    input               load_CA_REG_Y,
    input               load_REG_WC,
    input               load_REG_WS,
    input               load_PJ,
    output wire [1:0]    Zj
);

    wire signed [1:0]  xj_plus_4;
    wire signed [1:0]  yj_plus_4;

    wire signed [N-1:0]  xj;
    wire signed [N-1:0]  xj_complete;
    wire signed [N-1:0]  yj_plus_1;
    wire signed [N-1:0]  yj_plus_1_complete;

    wire signed [N-1:0]  selector_x_out;
    wire signed [N-1:0]  selector_y_out;

    wire signed [N+1:0]  WS;
    wire signed [N+1:0]  WC;

    wire signed [N+1:0]  CSA_out_S;
    wire signed [N+1:0]  CSA_out_C;
    wire signed [3:0]    v_estimate;
    wire signed [1:0]    selm_out;
    wire signed [3:0]    M_out;




    register #(2) LX (
        .clk(clk),
        .rst(rst),
        .load(load_LX),
        .d(xj_plus_5),
        .q(xj_plus_4)
    );
    register #(2) LY (
        .clk(clk),
        .rst(rst),
        .load(load_LY),
        .d(yj_plus_5),
        .q(yj_plus_4)
    );


    CA_REG #(N) CA_REG_X (
        .clk(clk),
        .rst(rst),
        .load(load_CA_REG_X),
        .inp(xj_plus_4),
        .orig_value(xj),
        .complete_value(xj_complete)
    );
    CA_REG #(N) CA_REG_Y (
        .clk(clk),
        .rst(rst),
        .load(load_CA_REG_Y),
        .inp(yj_plus_5),
        .orig_value(yj_plus_1),
        .complete_value(yj_plus_1_complete)
    );


    SELECTOR #(N) SELECT_X (
        .sel(yj_plus_4),
        .X(xj),
        .X_COMP(xj_complete),
        .out(selector_x_out)
    );
    SELECTOR #(N) SELECT_Y (
        .sel(xj_plus_4),
        .X(yj_plus_1),
        .X_COMP(yj_plus_1_complete),
        .out(selector_y_out)
    );

         
    CSA_4_2 #(N) _CSA_4_2(
        .X({{2{selector_x_out[N-1]}}, selector_x_out[N-1:2]}),
        .Y({{2{selector_y_out[N-1]}}, selector_y_out[N-1:2]}),
        .Z(WS),
        .W(WC),
        .Cin1(xj_plus_4[1]),
        .Cin2(yj_plus_4[1]),
        .sum(CSA_out_S),
        .carry(CSA_out_C)
    );

    wire overflow_V;
    Adder #(4) V_estimator(
        .A(CSA_out_S[N+1:N-2]),
        .B(CSA_out_C[N+1:N-2]),
        .Sum(v_estimate),
        .Overflow(overflow_V)
    );

    SEL_M selm(
        .in({{v_estimate}}),
        .out(selm_out)
    );

    subtractor #(
    .N(4)
    ) M(
        .X(v_estimate),
        .Y({selm_out, 2'b0} & {4{load_PJ}}),
        .Z(M_out)
    );


    register #(
    .N(N+4)
    ) REG_WC(
        .clk(clk),
        .rst(rst),
        .load(load_REG_WC),
        .d({M_out[2:0], CSA_out_C[N-3:0], 1'b0}),
        .q(WC)
    );

    register #(
        .N(N+4)
        ) REG_WS(
            .clk(clk),
            .rst(rst),
            .load(load_REG_WS),
            .d({3'b0, CSA_out_S[N-3:0], 1'b0}),
            .q(WS)
        );

    assign Zj = selm_out;
endmodule
