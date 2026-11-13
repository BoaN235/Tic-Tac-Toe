/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_tic_tac_toe (
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n,    // reset_n - low to reset
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,  // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out, // IOs: Output path
    output wire [7:0] uio_oe   // IOs: Enable path (active high: 0=input, 1=output)
);

 // List all unused inputs to prevent warnings
assign uio_out = 8'b00000000;
assign uio_oe  = 8'b00000000;
wire _unused = &{ena, uio_in, 1'b0};

wire command [7:0];

program_block block (clk, reset, 1'b1, ui_in, 1'b1, command);

assign uo_out = command

endmodule

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
cmd_add add (clk, reset, selector);
cmd_sub subtract (clk, reset, selector);
cmd_mul multiply (clk, reset, selector);
cmd_div divide (clk, reset, selector);


always @(command) begin
    if (selector = 15) begin
        case (command [3:0])
            4'b0000:   selector = 0; // 0000 End x
            4'b0001:   selector = 1; // 0001 Read (output Num at address) Done
            4'b0010:   selector = 2; // 0010 Save (Save -> at address) Done
            4'b0011:   selector = 3; // 0011 Add (Num at address + Num at address ->) x
            4'b0100:   selector = 4; // 0100 Subtract (Num at address - Num at address ->) x
            4'b0101:   selector = 5; // 0101 Multiply (Num at address * Num at address ->) x
            4'b0110:   selector = 6; // 0110 Divide (Num at address / Num at address ->) x
            4'b0111:   selector = 7; // 0111 Write (Save Num x at address) Done
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

module program_block(
    input clk,
    input reset,

    input data_valid,
    input [7:0] incoming_data,

    input read_enable,

    output [7:0] read_data
)

reg we = 1'b1;
reg download = 1'b1;

wire [7:0] read_address;

// clock counter
reg [7:0] write_address;
always @(posedge clk) begin
    if (reset) begin
            write_address <= 0;
            we = 1'b1; // set write
    end
    else if (data_valid) begin
        write_address <= write_address + 1;
    end 
    
    if (write_address >= 15) begin
    download = 1'b0;
end
end



reg [7:0] program_counter = 15;
always @(posedge clk) begin
    if (!download & program_counter >= 15) begin
            program_counter <= 0;
            we = 1'b0; // set read
    end
    else if (data_valid) begin 
        program_counter <= program_counter + 1;
    end
end

program_ram ram1 (
    .clk(clk), 
    .addr(data_valid ? write_address : read_address),
    .data_in(incoming_data),
    .data_out(program_counter),
    .cs(data_valid | read_enable),
    .we(we)
    );
    assign read_data = ram_data_out;

endmodule


module number_ram
  # (parameter ADDR_WIDTH = 4,
     parameter DATA_WIDTH = 8,
     parameter DEPTH = 16               // Number of words; normally 2**ADDR_WIDTH
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


module program_ram
  # (parameter ADDR_WIDTH = 4,
     parameter DATA_WIDTH = 16,
     parameter DEPTH = 16               // Number of words; normally 2**ADDR_WIDTH
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

// cmds
// 0000 Read (output Num at address)
// 0001 Save (Save -> at address)
// 0010 Add (Num at address + Num at address ->)
// 0011 Subtract (Num at address - Num at address ->)
// 0100 Multiply (Num at address * Num at address ->)
// 0101 Divide (Num at address / Num at address ->)
// 0111 Write (Save Num x at address)

// 1 2 4 8  16 32 64 128  -  255
// 0000     0000 