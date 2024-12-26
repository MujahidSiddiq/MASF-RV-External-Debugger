`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2024 12:55:53 PM
// Design Name: 
// Module Name: uncond_str_element
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


module uncond_str_element(
    input logic clk, Stall,
    input logic [31:0] in,
    output logic [31:0] out,
    input logic reset_stages
);

// Registers to hold the output value
logic [31:0] out_reg;
// initial begin
//     out_reg = 0;

// end

// Always block to update the output register
always_ff @(posedge clk) begin
    if(reset_stages) begin 
        out_reg <= 0;
    end
    else if (!Stall) begin
        // Update output if not stalled
        out_reg <= in;
    end else begin
        // Retain the previous value of the output when stalled
        out_reg <= out_reg;
    end
end

// Assign output to the registered value
assign out = out_reg;

endmodule

