/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
*/

`default_nettype none

module tt_um_tic_tac_toe (
    //input  wire [7:0] a_in,   // Dedicated inputs
    //input  wire [7:0] b_in,
    //output wire [8:0] out,   // Dedicated outputs
    //input  wire [2:0] operation,
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
wire _unused = &{ena, rst_n, uio_in[7:2], 1'b0};

wire command [7:0]

program_block block (clk, reset, 1'b1, ui_in, 1'b1, command);


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
reg executing_cmd [3:0] // cmd being executed

cmd_read read (clk, reset, executing_cmd, working_mem, executing, address, output_bool);
cmd_save save (clk, reset, executing_cmd, working_mem, executing, data_out, address, output_bool);

always @(command) begin
    if (executing == 0) begin
        working_mem = 16'b0000000000000000
        executing_cmd = command
        case (command) // amount of time it takes for each cmd to execute 1 should be last step
            4'b0000:   executing = 0; // 0000 End
            4'b0001:   executing = 2; // 0001 Read (output Num at address)
            4'b0010:   executing = 2; // 0010 Save (Save -> at address)
            4'b0011:   executing = 4; // 0011 Add (Num at address + Num at address ->)
            4'b0100:   executing = 4; // 0100 Subtract (Num at address - Num at address ->)
            4'b0101:   executing = 4; // 0101 Multiply (Num at address * Num at address ->)
            4'b0110:   executing = 4; // 0110 Divide (Num at address / Num at address ->)
            4'b0111:   executing = 3; // 0111 Write (Save Num x at address)
            default: executing = 0 executing_cmd = 0; // 0000 End
        endcase
    end else begin
        case (executing)
        0: working_mem = working_mem
        1: working_mem = {command, working_mem [15:4]}
        2: working_mem = {working_mem [3:0] command, working_mem [15:8]}
        3: working_mem = {working_mem [7:0] command, working_mem [15:12]}
        4: working_mem = {working_mem [11:0] command}
        endcase
        executing = executing - 1;
    end
end

number_ram ram1 (
    .clk(clk),
    .addr(address),
    .data_in(incoming_data),
    .data_out(output_bool ? data_out : output_data),
    .cs(data_valid | read_enable),
    .ws(1'b1)
);



endmodule

module cmd_read (input clk, input reset, input command, input working_mem, input executing_cmd, output output_address, output output_bool)

reg output_addr_reg

always @(command) begin
    if (executing_cmd == 1 & executing = 1) begin
        output_addr_reg = working_mem [0:3] 
    end
end

assign output_address = output_addr_reg
assign output_bool = 1

endmodule

module cmd_save (input clk, input reset, input command, input working_mem, input executing_cmd, saved_data, output save_address, output output_bool, output save_data)

reg save_addr_reg
reg save_data_reg

always @(saved_data) begin
    case (executing)

    endcase
end

always @(command) begin
    if (executing_cmd == 2 & executing = 1) begin
        save_addr_reg = working_mem [0:3] 
        save_data_reg = working_mem [4:11] 
    end
end

assign save_data = save_data_reg 
assign save_address = save_addr_reg
assign output_bool = 0

endmodule

module cmd_write (input clk, input reset, input command, )

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
reg download = 1'b1

wire [7:0] read_address

// clock counter
reg [7:0] write_address;
always @(posedge clk) begin
    if (reset & download) begin
            write_address <= 0;
            we = 1'b1; // set write
    end
    else if (data_valid) begin
        write_address <= write_address + 1;
    end
end

if (write_address >= 255) begin
    download = 1'b0
end

reg [7:0] program_counter = 225;
always @(posedge clk) begin
    if (!download & program_counter >= 255) begin
            program_counter <= 0;
            we = 1'b0 // set read
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
  # (parameter ADDR_WIDTH = 8,
     parameter DATA_WIDTH = 4,
     parameter DEPTH = 32               // Number of words; normally 2**ADDR_WIDTH
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