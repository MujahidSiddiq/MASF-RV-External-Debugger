`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 11:06:52 PM
// Design Name: 
// Module Name: IR_2nd_stage
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


module IR_2nd_stage(
    input logic clk, Stall, Flush,
    input logic [31:0] in,
    output logic [31:0] out,
    input logic reset_stages
 
);

// Registers to hold the output value
logic [31:0] out_reg;

initial begin
    out_reg = 32'h00000013;
end



always @(posedge clk) begin
    if ((Flush | reset_stages)) begin
        // If Flush is asserted, reset the output
        out_reg <= 32'h00000013;
    end else if (!Stall) begin
        // If Stall is not asserted, update the output
        out_reg <= in;
    end else begin
        // If Stall is asserted, retain the previous value of the output
        out_reg <= out_reg;
    end
end


// Assign output to the registered value
assign out = out_reg;

endmodule

