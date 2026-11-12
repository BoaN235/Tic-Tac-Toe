/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tic_tac_toe (
    input  wire [7:0] a_in,    // Dedicated inputs
    input  wire [7:0] b_in, 
    output wire [8:0] out,   // Dedicated outputs
    input  wire [2:0] operation,
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n,     // reset_n - low to reset
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
);

    //wire [8:0] add_out; // Adjust bit-width to match your signals
    //wire [8:0] sub_out;

    // Instantiate both hardware modules permanently
    add add_num (a_in, b_in, out);
    //subtract sub_num (a_in, b_in, sub_out);

    // Select the desired result
    //always @(*) begin
    //    if (operation == 2'b00) begin
    //        out = add_out;
    //    end else begin
    //        out = sub_out;
    //    end
    //end

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0, operation, uio, ui, uo};

endmodule


module add (
    input  wire [7:0] a_in,    // Dedicated inputs
    input  wire [7:0] b_in,
    output wire [8:0] out
    );

    wire [7:0] carry;
    add_operation digit_1 (a_in [0], b_in [0], 1'b0, out [0], carry[0]);
    add_operation digit_2 (a_in [1], b_in [1], carry[0], out [1], carry[1]);
    add_operation digit_3 (a_in [2], b_in [2], carry[1], out [2], carry[2]);
    add_operation digit_4 (a_in [3], b_in [3], carry[2], out [3], carry[3]);
    add_operation digit_5 (a_in [4], b_in [4], carry[3], out [4], carry[4]);
    add_operation digit_6 (a_in [5], b_in [5], carry[4], out [5], carry[5]);
    add_operation digit_7 (a_in [6], b_in [6], carry[5], out [6], carry[6]);
    add_operation digit_8 (a_in [7], b_in [7], carry[6], out [7], carry[7]);
    assign out [8] = carry [7];

endmodule

module subtract (
    input  wire [7:0] a_in,    // Dedicated inputs
    input  wire [7:0] b_in,
    output wire [8:0] out
    );

    // Twos compliment of B
   // wire i_b = (~b_in);
    //wire t_b [8:0];
    //add twos_compliment (t_b);

    // add A and negative B
    //wire added [8:0];
    //add add_negative (a_in, t_b, added);

    // check if the output is postive or twos compliment form
    //if (added [8] == 1'b0) begin
    //    assign added = (~added);
    //    add twos_compliment (added, 8'b00000001, out);
   // end else begin
    //    assign out = added;
    //end

endmodule

module add_operation (
    input wire a,
    input wire b,
    input wire c_in,
    output wire sum,
    output wire c_out
);

assign sum = (a ^ b) ^ c_in;
    assign c_out = ((a ^ b) & c_in) | a & b;
endmodule