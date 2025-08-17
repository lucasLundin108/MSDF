module controller#(
    parameter N = 9
)(
    input clk,
    input rst,
    
    output reg load_LX,
    output reg load_LY,
    output reg load_CA_REG_X,
    output reg load_CA_REG_Y,
    output reg load_REG_WC,
    output reg load_REG_WS,
    output reg load_PJ,
    output reg ready_Zj
);

reg [7:0] counter;

always @(negedge rst, posedge clk) begin
    if (!rst) begin
        counter <= 0;
        load_LX <= 1'b1;
        load_LY <= 1'b1;
        load_CA_REG_X <= 1'b0;
        load_CA_REG_Y <= 1'b1;
        load_REG_WC <= 1'b1;
        load_REG_WS <= 1'b1;
        load_PJ <= 1'b0;
        ready_Zj <= 1'b0;
    end else begin
        if(counter == 0)begin
            counter <= counter + 1'b1;
            load_CA_REG_X <= 1'b1;
        end else if (counter < 2) begin
            counter <= counter + 1'b1;
        end else if (counter==3) begin
            ready_Zj <= 1'b1;
            counter <= counter + 1'b1;
        end else if(counter < N-2)begin
            load_PJ <= 1'b1;
            counter <= counter + 1'b1;
        end else if(counter == N-2)begin
            counter <= counter + 1'b1;
        end else if(counter == N-1)begin
            counter <= counter + 1'b1;
            load_LY <= 1'b0;
            load_LX <= 1'b0;
        end else if(counter == N)begin
            load_CA_REG_Y <= 1'b0;
            counter <= counter + 1'b1;
        end else if(counter == N+1)begin
            load_CA_REG_X <= 1'b0;
            counter <= counter + 1'b1;
        end
    end
end
endmodule