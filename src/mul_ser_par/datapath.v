module datapath#(
    parameter N = 8
)(
    input               clk,
    input               rst,
    input [N:0]         Y,
    input [1:0]         xj_plus_4,
    input               load_CA_REG_Y,
    input               load_REG_WC,
    input               load_REG_WS,
    input               load_PJ,
    output wire [1:0]    Zj
);
    wire signed [N:0]  yj_plus_1;
    wire signed [N:0]  yj_plus_1_complete;

    wire signed [N+2:0]  selector_y_out;

    wire signed [N+3:0]  WS;
    wire signed [N+3:0]  WC;

    wire signed [N+3:0]  CSA_out_S;
    wire signed [N+3:0]  CSA_out_C;
    wire signed [3:0]    v_estimate;
    wire signed [1:0]    selm_out;
    wire signed [2:0]    M_out;


    CA_REG_A #(N+1) CA_REG_Y (
        .clk(clk),
        .rst(rst),
        .load(load_CA_REG_Y),
        .inp(Y),
        .orig_value(yj_plus_1),
        .complete_value(yj_plus_1_complete)
    );

    SELECTOR #(N+3) SELECT_Y (
        .sel(xj_plus_4),
        .X({{2{yj_plus_1[N]}}, yj_plus_1[N:0]}),
        .X_COMP({{2{yj_plus_1_complete[N]}}, yj_plus_1_complete[N:0]}),
        .out(selector_y_out)
    );

         
    CSA_3_2 #(N) _CSA_3_2(
        .Y(selector_y_out),
        .Z(WC),
        .X(WS),
        .Cin(xj_plus_4[1]),
        .sum(CSA_out_S),
        .carry(CSA_out_C)
    );

    wire overflow_V;
    Adder #(4) V_estimator(
        .A(CSA_out_S[N+3:N]),
        .B(CSA_out_C[N+3:N]),
        .Sum(v_estimate),
        .Overflow(overflow_V)
    );

    SEL_M selm(
        .in({{v_estimate}}),
        .out(selm_out)
    );

    M _M(
        .X(v_estimate),
        .Y({selm_out} & {2{load_PJ}}),
        .Z(M_out)
    );


    register #(
    .N(N+4)
    ) REG_WS(
        .clk(clk),
        .rst(rst),
        .load(load_REG_WS),
        .d({M_out[2:0], CSA_out_S[N-1:0], 1'b0}),
        .q(WS)
    );

    register #(
        .N(N+4)
        ) REG_WC(
            .clk(clk),
            .rst(rst),
            .load(load_REG_WC),
            .d({3'b0, CSA_out_C[N-1:0], 1'b0}),
            .q(WC)
        );

    assign Zj = selm_out;
endmodule
