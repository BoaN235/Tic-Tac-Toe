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

module program_ram
  # (parameter ADDR_WIDTH = 8,
     parameter DATA_WIDTH = 24,
     parameter DEPTH = 256               // Number of words; normally 2**ADDR_WIDTH
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