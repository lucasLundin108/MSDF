module controller#(
    parameter N = 9
)(
    input clk,
    input rst,
    input start,

    output reg load_REG_WC,
    output reg load_REG_WS,
    output reg load_PJ,
    output reg ready_Zj
);

reg [7:0] counter;

always @(negedge rst, posedge clk) begin
    if (!rst || start) begin //
        counter <= 0;
        load_REG_WC <= 1'b0;
        load_REG_WS <= 1'b0;
        load_PJ <= 1'b0;
        ready_Zj <= 1'b0;
        load_REG_WC <= 1'b1;
        load_REG_WS <= 1'b1;
    end else begin
        if (counter == 0) begin
            load_REG_WC <= 1'b1;
            load_REG_WS <= 1'b1;
            counter <= counter + 1'b1;
        end
        else if (counter < 3) begin
            counter <= counter + 1'b1;
        end else if (counter==3) begin
            ready_Zj <= 1'b1;
            load_PJ <= 1'b1;
            counter <= counter + 1'b1;
        end else begin
            counter <= counter + 1'b1;
        end
        end
    end
endmodule

//0100110101010
//1000110101010