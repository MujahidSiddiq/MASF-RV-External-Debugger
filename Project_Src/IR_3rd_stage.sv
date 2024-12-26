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


module IR_3rd_stage(
    input logic clk, 
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

    if(reset_stages) begin
        out_reg <= 32'h00000013;
    end
    
    else begin
        out_reg <= in;

    end
   
end

// Assign output to the registered value
assign out = out_reg;

endmodule

