module controller#(
    parameter N = 9
)(
    input clk,
    input rst,
    
    output reg load_L_LEVEL1,
    output reg load_L_LEVEL2,
    output reg load_L_LEVEL3,
    output reg ready_Zj
);

reg [7:0] counter;

always @(negedge rst or posedge clk) begin
    if (!rst) begin
        counter <= 0;
        load_L_LEVEL1 <= 1'b0;
        load_L_LEVEL2 <= 1'b0;
        load_L_LEVEL3 <= 1'b0;
        ready_Zj <= 1'b0;
    end else begin
        if(counter == 2)begin
            counter <= counter + 1'b1;
            ready_Zj <= 1'b1;
        end
        else if(counter < N+2)begin
            load_L_LEVEL1 <= 1'b1;
            load_L_LEVEL2 <= 1'b1;
            load_L_LEVEL3 <= 1'b1;
            counter <= counter + 1'b1;
        end
    end
end
endmodule