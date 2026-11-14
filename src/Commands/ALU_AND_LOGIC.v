module cmd_math (input clk, input reset, input selector, input command, output working_mem)

wire [8:0] added;
wire [8:0] subtracted;
wire [8:0] multiplied;
wire [8:0] divided;

cmd_add add (clk, reset, added);
cmd_sub subtract (clk, reset, subtracted);
cmd_mul multiply (clk, reset, multiplied);
cmd_div divide (clk, reset, divided);

reg [8:0] product;

always @(*) begin
    if (selector = 5) begin
        case (command [5:4]) 
            2'b00: product = added;
            2'b01: product = subtracted;
            2'b10: product = multiplied;
            2'b11: product = divided;
        endcase
    end
end

assign working_mem = product

endmodule