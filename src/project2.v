/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tic_tac_toe (
    //input  wire [7:0] a_in,    // Dedicated inputs
    //input  wire [7:0] b_in, 
    //output wire [8:0] out,   // Dedicated outputs
    //input  wire [2:0] operation,
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n,     // reset_n - low to reset
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe   // IOs: Enable path (active high: 0=input, 1=output)
);

    always @(*) begin
        case (uio_in[1:0])
            2'b00: out =  ui_in[4:0] + ui_in[7:5]
            2'b01: out =  ui_in[4:0] - ui_in[7:5]
        endcase
    end

  // List all unused inputs to prevent warnings
  assign uio_out = 8'b00000000;
  assign uio_oe  = 8'b00000000;
  wire _unused = &{ena, clk, rst_n, 1'b0};

endmodule