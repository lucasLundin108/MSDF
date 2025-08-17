module datapath#(
    parameter N = 8
)(
    input               clk,
    input               rst,
    input signed [1:0]  xj_plus_3,
    input signed [1:0]  yj_plus_3,
    input               load_L_LEVEL1,
    input               load_L_LEVEL2,
    input               load_L_LEVEL3,
    output wire [1:0]   Zj
);

    function [1:0] to_redandant;
    input [1:0] in;
    begin
        case (in)
            2'b11: to_redandant = 2'b01;
            2'b00: to_redandant = 2'b00;
            2'b01: to_redandant = 2'b10;
            default: to_redandant = 2'b00;
        endcase
    end
    endfunction

    function [1:0] to_2complement;
    input [1:0] in;
    begin
        case (in)
            2'b01: to_2complement = 2'b11;
            2'b00: to_2complement = 2'b00;
            2'b10: to_2complement = 2'b01;
            default: to_2complement = 2'b00;
        endcase
    end
    endfunction


    wire [1:0] L_LEVEL_1_out;
    wire L_LEVEL_2_out;
    wire [1:0] L_LEVEL_3_out;


    wire [1:0] FA1_out;
    wire [1:0] FA2_out;


    wire [1:0] redandant_xj_plus_3 = to_redandant(xj_plus_3);
    wire [1:0] redandant_yj_plus_3 = to_redandant(yj_plus_3);

    FA FA1 (
        .a(redandant_xj_plus_3[1]),
        .b(~redandant_xj_plus_3[0]),
        .cin(redandant_yj_plus_3[1]),
        .sum(FA1_out[0]),
        .cout(FA1_out[1])
    );

    register #(2) L1 (
        .clk(clk),
        .rst(rst),
        .load(load_L_LEVEL1),
        .d({~FA1_out[0], redandant_yj_plus_3[0]}),
        .q(L_LEVEL_1_out)
    );

    FA FA2 (
        .a(~L_LEVEL_1_out[0]),
        .b(~L_LEVEL_1_out[1]),
        .cin(FA1_out[1]),
        .sum(FA2_out[0]),
        .cout(FA2_out[1])
    );

    register #(1) L2 (
        .clk(clk),
        .rst(rst),
        .load(load_L_LEVEL2),
        .d(FA2_out[0]),
        .q(L_LEVEL_2_out)
    );

    register #(2) L3 (
        .clk(clk),
        .rst(rst),
        .load(load_L_LEVEL3),
        .d({~FA2_out[1], L_LEVEL_2_out}),
        .q(L_LEVEL_3_out)
    );

    assign Zj = to_2complement({L_LEVEL_3_out[0], L_LEVEL_3_out[1]});
    
endmodule
