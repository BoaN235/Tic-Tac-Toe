module command_block(
    input clk,
    input reset,
    input [3:0] command
    output output_data [7:0]
)

reg read_address [3:0]; // address for read
reg out_data = 8'b00000000; // data being outputted 
assign output_data = out_data; // assigning the output data

reg executing = 0; // current execution time
reg working_mem [15:0]; // current values being edited
reg numbers [23:0];
reg executing_cmd [3:0]; // cmd being executed
reg [7:0] selector = 15;

cmd_read read (clk, reset, selector, address, output_bool, read_write);
cmd_save save (clk, reset, selector, working_mem, data_out, address, output_bool, read_write);
cmd_write write (clk, reset, selector, address, output_bool, read_write);
cmd_math math (clk, reset, selector, command, working_mem);
cmd_logic logic (clk, reset, selector, command, working_mem);

always @(command) begin
    if (selector = 0) begin // I split it up so its easier to read and understand each cmd
        case (command [3:0])  // -> = return value to working memory when cmd ends
            4'b0000:   selector = 0; // 0000 End x
                                // [ DATA TRANSFER - saving or reading data ]
            4'b0001:   selector = 1;  // 0001 Read (output Num at address) Done
            4'b0010:   selector = 2;  // 0010 Save (Save -> at address) Done
            4'b0011:   selector = 3;  // 0011 Write (Save Num x at address) Done
            4'b0100:   selector = 4;  // 0100 Move (Move value @ address x to address y) x
                                // [ ALU - Math & Logic ]
            4'b0101:   selector = 5;  // 0101 Math (See Math Instructions) x
            4'b0111:   selector = 6;  // 1001 Logic () x
            4'b1001:   selector = 9; // 1010 Or () x
            4'b1010:   selector = 10; // 1011 invert () x
            4'b1011:   selector = 11; // 1100 left/right shift () x
                                // [ Control FLow - Functions & Conditionals ]
            4'b1100:   selector = 12;  // 1100 If () x
            4'b1101:   selector = 13;  // 1100 Return () x
            4'b1110:   selector = 14;  // 1100 Jump () x
            4'b1111:   selector = 14;  // 1100 Wait () x
            default: selector = 0;  // 0000 End
        endcase
    end
end

number_ram ram1 (
    .clk(clk),
    .addr(address),
    .data_in(incoming_data),
    .data_out(output_bool ? data_out : output_data),
    .cs(data_valid | read_enable),
    .ws(read_write)
);

endmodule


module number_ram
  # (parameter ADDR_WIDTH = 7,
     parameter DATA_WIDTH = 9,
     parameter DEPTH = 128               // Number of words; normally 2**ADDR_WIDTH
    )

  ( 	input 					clk,
   		input [ADDR_WIDTH-1:0]	addr,
   		inout [DATA_WIDTH-1:0]	data,
   		input 					cs,		// Chip Select
   		input 					we,		// Write Enable
   		input 					oe		// Output Enable
  );

  reg [DATA_WIDTH-1:0] 	tmp_data;       // Read data register
  reg [DATA_WIDTH-1:0] 	mem [0:DEPTH-1];   // Storage: DEPTH words of DATA_WIDTH bits

  // Synchronous write: store the bus value at the clock edge
  always @ (posedge clk) begin
    if (cs & we)
      mem[addr] <= data;
  end

  // Synchronous read: capture the addressed word at the clock edge
  always @ (posedge clk) begin
    if (cs & !we)
    	tmp_data <= mem[addr];
  end

  // Drive the bus only while reading with output enabled; release it otherwise
  assign data = cs & oe & !we ? tmp_data : 'hz;
endmodule