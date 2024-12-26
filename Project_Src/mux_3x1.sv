`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 05:08:14 PM
// Design Name: 
// Module Name: mux_3x1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux_3x1 (
    input logic [1:0] select,       // Select lines
    input logic [31:0] data0,    // Input data line 0
    input logic [31:0] data1,    // Input data line 1
    input logic [31:0] data2,    // Input data line 2
    output logic [31:0] out      // Output data line
);

    always_comb begin
        case(select)
            2'b00: out = data0;  // Select input data line 0 when sel is 00
            2'b01: out = data1;  // Select input data line 1 when sel is 01
            2'b10: out = data2;  // Select input data line 2 when sel is 10
            default: out = 32'b0; // Default output (in case of invalid select lines)
        endcase
    end

endmodule