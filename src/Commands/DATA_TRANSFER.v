module cmd_read (input clk, input reset, input command, input executing_cmd, output output_address, output output_bool, output read_write)

reg [3:0] output_addr_reg;
reg output_bool_reg;
reg read_write_reg;

always @(posedge clk) begin
    if (selector == 0) begin
        output_addr_reg <= command[7:4];
        output_bool <= 1'b1;
        read_write <= 1'b1;
    end
end

assign output_address = output_addr_reg;
assign output_bool = output_bool_reg;
assign read_write = read_write_reg;



endmodule

module cmd_save (input clk, input reset, input command, input working_mem, input executing_cmd, saved_data, output save_address, output output_bool, output save_data, output read_write)

reg save_addr_reg;
reg save_data_reg;
reg output_bool_reg;
reg read_write_reg;

always @(posedge clk) begin
    if (selector == 1) begin
        save_addr_reg <= command [7:4];
        save_data_reg <= working_mem [7:0];
        output_bool <= 1'b0;
        read_write <= 1'b1;
    end;
end

assign save_data = save_data_reg;
assign save_address = save_addr_reg;
assign output_bool = output_bool_reg;
assign read_write = read_write_reg;


endmodule

module cmd_write (input clk, input reset, input command, input executing_cmd, saved_data, output save_address, output output_bool, output save_data, output read_write)

reg save_addr_reg;
reg save_data_reg;
reg output_bool_reg;
reg read_write_reg;

always @(posedge clk) begin
    if (selector == 1) begin
        save_addr_reg <= command [7:4];
        save_data_reg <= command [15:8];
        output_bool <= 1'b0;
        read_write <= 1'b0;
    end;
end

assign save_data = save_data_reg;
assign save_address = save_addr_reg;
assign output_bool = output_bool_reg;
assign read_write = read_write_reg;

endmodule